///usr/bin/env go run $0 $@; exit
package main

import (
//	"bytes"
	_ "github.com/lib/pq"
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net"
	"net/http"
//	"net/url"
	"strconv"
	"sync"
	"time"

	/* Own tools */
	"./ap"
)

/* Global variables */
var db *sql.DB
var client *http.Client
var ap_defaultsite string
var ap_database string

/* Realm used for authentication */
var realm = "ACS"

/* Password for when we contact ACSdb */
var ad_username string
var ad_password string

/* Password for when ACSdb contacts us */
var ag_username string
var ag_password string

var tool_title = "ACSgw - ACS Gateway"

func user_check(user string, pass string, ip string) int {
	if user == ag_username && pass == ag_password {
		return 1
	} else if user == "admin" && (ip == "127.0.0.1" || ip == "::1") {
		return 2
	}

	log.Println("No such user: " + user + " on IP " + ip)

	return 0
}

/* Send a request to ACSdb */
func ask_db(url string, json string) (body string, err error, response *http.Response) {
	log.Println(ap_database + url)
	return ap.HTTP_Action(ap_database + url, "", nil, ad_username, ad_password, json);
}

func jsondec(jsontxt string, m interface{}) (err error) {
	return json.Unmarshal([]byte(jsontxt), &m)
}

func getparams(w http.ResponseWriter, r *http.Request, m interface{}) bool {
	if r.Method != "POST" {
		result(w, "error", "Requests need to be POSTed")
		return false
	}

	dec := json.NewDecoder(r.Body)

	/* Expect multiple objects, even if we only want one */
	for {
		err := dec.Decode(&m)
		if err == io.EOF {
			break;
		} else if err != nil {
			result(w, "error", err.Error())
			return false
		}
	}

	return true;
}

func result(w http.ResponseWriter, state string, message string) {
	w.Header().Set("Content-Type", "application/json")

	m := ap.Result{state, message}
	j, err := json.MarshalIndent(m, "", "\t")

	if err != nil {
		/* Should never happen, thus abort */
		panic(err)
	}

	w.Write(j);
}

func h_root(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")

	fmt.Fprintf(w, tool_title)
}

func status_tot(table string) (int) {
	var tot int;

	rows, err := db.Query("SELECT COUNT(*) FROM " + table)
	defer rows.Close()

	if err != nil {
		panic(err)
		return 0
	}

	for rows.Next() {
		err := rows.Scan(&tot)
		if err != nil {
			log.Fatal(err)
		}

		return tot
	}

	return 0
}

func status_tot_addr() (int) {
	var tot int;

	rows, err := db.Query(
			"SELECT SUM(2 ^ ((CASE WHEN family(prefix) = 6 THEN 128 ELSE 32 END)- MASKLEN(prefix))) " +
			"FROM pools")
	defer rows.Close()

	if err != nil {
		panic(err)
		return 0
	}

	defer rows.Close()
	for rows.Next() {
		err := rows.Scan(&tot)
		if err != nil {
			log.Fatal(err)
		}

		return tot
	}

	return 0
}

func status_tot_lst(lstate string) (int) {
	var tot int;

	rows, err := db.Query(
			"SELECT COUNT(*) " +
			"FROM listeners " +
			"WHERE state = $1",
			lstate)
	defer rows.Close()

	if err != nil {
		panic(err)
		return 0
	}

	defer rows.Close()
	for rows.Next() {
		err := rows.Scan(&tot)
		if err != nil {
			log.Fatal(err)
		}

		return tot
	}

	return 0
}

func h_status(w http.ResponseWriter, r *http.Request) {

	pool_num	:= status_tot("pools")
	pool_addr	:= status_tot_addr();
	lst_initials	:= status_tot_lst("initial")
	lst_redirects	:= status_tot_lst("redirect")
	lst_relays	:= status_tot_lst("relay")

	m := ap.Status{
		ap.StatusPools{pool_num, pool_addr},
		ap.StatusListeners{lst_initials, lst_redirects, lst_relays}}
	j, err := json.MarshalIndent(m, "", "\t")

	if err != nil {
		result(w, "error", err.Error())
	} else {
		w.Write(j)
	}
}

func h_reset(w http.ResponseWriter, r *http.Request) {
	result(w, "ok", "TODO: Not Implemented")
}

func lst_add(address string, port int, cookie string, state string) (l_id int) {
	var pool_id = -1
	l_id = -1

	rows, err := db.Query(
			"SELECT l_id, pool_id, cookie, state " +
			"FROM listeners " +
			"WHERE address = $1 ",
			address)
	defer rows.Close()

	if err != nil {
		panic(err)
		return -1
	}

	for rows.Next() {
		var lstate string
		var lcookie string

		err := rows.Scan(&l_id, &pool_id, &lcookie, &lstate)
		if err != nil {
			log.Fatal(err)
		}

		if lstate != state {
			log.Fatal("Existing listener with different state (" + lstate + " vs " + state + ")")
			return -1
		}

		/*
		 * We do not check if the cookie name is different
		 * (only initials need consistent cookies, redirect/relay do not)
		 */

		if (state == "initial" && cookie != lcookie) {
			log.Fatal("Existing initial listener with different cookie")
			return -1
		}
	}

	rows.Close()

	if l_id != -1 {
		return l_id
	}

	rows, err = db.Query(
		"SELECT pool_id " +
		"FROM pools " +
		"WHERE prefix >>= $1 ",
		address)
	defer rows.Close()

	if err != nil {
		panic(err)
		return -1
	}

	for rows.Next() {
		err := rows.Scan(&pool_id)
		if err != nil {
			log.Fatal(err)
			return -1
		}
	}

	rows.Close()

	if pool_id < 0 {
		log.Println("No such pool for address " + address)
		return -1
	}

	rows, err = db.Query(
		"INSERT INTO listeners " +
		"(pool_id, address, port, cookie, state) " +
		"VALUES($1, $2, $3, $4, $5) " +
		"RETURNING l_id",
		pool_id, address, port, cookie, state)
	defer rows.Close()

	if err != nil {
		panic(err)
		return -1
	}

	for rows.Next() {
		err := rows.Scan(&l_id)
		if err != nil {
			panic(err)
			return -1
		}
	}

	/* Got it */
	return l_id
}

func h_lst_add_initial(w http.ResponseWriter, r *http.Request) {
	var m ap.ListenerAddInitial

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	l_id := lst_add(m.Address, m.Port, m.Cookie, "initial")
	if (l_id < 0) {
		result(w, "error", "Failed to add Initial Listener")
	} else {
		result(w, "ok", "Added Initial Listener")
	}

	return
}

func h_lst_add_redirect(w http.ResponseWriter, r *http.Request) {
	var m ap.ListenerAddRedirect

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	l_id := lst_add(m.Address, m.Port, m.Cookie, "redirect")

	if (l_id < 0) {
		result(w, "error", "Failed to add Redirect Listener")
		return
	}

	/* Specific for this credential */
	rows, err := db.Query(
		"INSERT INTO redirects " +
		"(l_id, fullcookie, bridge) " +
		"VALUES($1, $2, $3)",
		l_id, m.FullCookie, m.Bridges)
	defer rows.Close()

	if err != nil {
		panic(err)
		return
	}

	result(w, "ok", "Added Redirect Listener")
}

func h_lst_add_relay(w http.ResponseWriter, r *http.Request) {
	var m		ap.ListenerAddRelay
	var br_id	int

	br_id = -1

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	/* Which bridge is this about? */
	rows, err := db.Query(
			"SELECT br_id " +
			"FROM bridges " +
			"WHERE identity = $1",
			m.Identity)
	defer rows.Close()

	if err != nil {
		panic(err)
		return
	}

	for rows.Next() {
		err := rows.Scan(&br_id)
		if err != nil {
			log.Fatal(err)
			return
		}
		break
	}
	rows.Close()

	if br_id == -1 {
		log.Fatal("No bridges found for identity " + m.Identity)
		return
	}

	l_id := lst_add(m.Address, m.Port, m.Cookie, "relay")

	if (l_id < 0) {
		result(w, "error", "Failed to add Redirect Listener")
		return
	}

	/* Specific for this credential */
	rows, err = db.Query(
		"INSERT INTO relays " +
		"(l_id, br_id, fullcookie) " +
		"VALUES($1, $2, $3)",
		l_id, br_id, m.FullCookie)
	defer rows.Close()

	if err != nil {
		panic(err)
		return
	}

	result(w, "ok", "Added Relay Listener")
}

func h_lst_remove(w http.ResponseWriter, r *http.Request) {
	var m ap.Id

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	result(w, "ok", "TODO: " + m.Id)
}

func h_block_add(w http.ResponseWriter, r *http.Request) {
	var m ap.Prefix

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	result(w, "ok", "TODO: " + m.Prefix)
}

func h_block_remove(w http.ResponseWriter, r *http.Request) {
	var m ap.Id

	ret := getparams(w, r, &m)
	if ret == false {
		return
	}

	result(w, "ok", "TODO: " + m.Id)
}

/* Custom ACS HTTP handler */
type ACS struct{}

func acs_proxy_copyheaders(source http.Header, dest *http.Header) {
	for n, v := range source {
		for _, vv := range v {
			dest.Add(n, vv)
		}
	}
}

func acs_proxy(realsrv string, w http.ResponseWriter, r *http.Request) {
	uri := realsrv + r.RequestURI

	/* Create a new request based on the current one */
	rr, err := http.NewRequest(r.Method, uri, r.Body)
	if err != nil {
		log.Println(err)
		return
	}

	acs_proxy_copyheaders(r.Header, &rr.Header)

	// Create a client and query the target
	var transport http.Transport
	resp, err := transport.RoundTrip(rr)
	if err != nil {
		log.Println("Request to backend-proxy failed")
		log.Println(err)
		w.Write([]byte("Request to backend-proxy failed"))
		return
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("Reading Body failed")
		log.Println(err)
		w.Write([]byte("Reading Body failed"))
		return
	}

	dH := w.Header()
	acs_proxy_copyheaders(resp.Header, &dH)
	dH.Add("Requested-Host", rr.Host)

	w.Write(body)
}

func acs_relay(w http.ResponseWriter, r *http.Request) (bool) {
	cookies := r.Cookies()

	/* Check all the cookies */
	for i:=0; i < len(cookies); i++ {
		log.Println("HTTP Cookie:", cookies[i].Name, "Value:", cookies[i].Value)

		/* Is this a valid redirect cookie? */
		cookie := cookies[i].Name + "=" + cookies[i].Value

		rows, err := db.Query(
				"SELECT type, identity, address, port " +
				"FROM relays " +
				"INNER JOIN bridges ON relays.br_id = bridges.br_id " +
				"WHERE fullcookie = $1",
				cookie)
		defer rows.Close()

		if err != nil {
			panic(err)
			return false
		}

		for rows.Next() {
			var bridge	string
			var btype	string
			var identity	string
			var address	string
			var port	string

			err := rows.Scan(&btype, &identity, &address, &port)
			if err != nil {
				log.Fatal(err)
				return false
			}

			log.Println("Bridging towards " + btype + " bridge " + identity)

			bridge = "http://" + address + ":" + port

			acs_proxy(bridge, w, r)
			return true
		}
	}

	/* Not found */
	return false
}

func acs_redirect(w http.ResponseWriter, r *http.Request) (bool) {
	cookies := r.Cookies()

	/* Check all the cookies */
	for i:=0; i < len(cookies); i++ {
		log.Println("HTTP Cookie:", cookies[i].Name, "Value:", cookies[i].Value)

		/* Is this a valid redirect cookie? */
		cookie := cookies[i].Name + "=" + cookies[i].Value

		rows, err := db.Query(
				"SELECT bridge " +
				"FROM redirects " +
				"WHERE fullcookie = $1",
				cookie)
		defer rows.Close()

		if err != nil {
			panic(err)
			return false
		}

		for rows.Next() {
			var bridge string

			err := rows.Scan(&bridge)
			if err != nil {
				log.Fatal(err)
				return false
			}

			w.Write([]byte(bridge))
			return true
		}
	}

	return false
}

func acs_handle(w http.ResponseWriter, r *http.Request) (string) {

	/* Debugging help */
	if true {
		for key, value := range r.Header {
			log.Println("HTTP Header:", key, "Value:", value)
		}

		log.Println("Host: " + r.Host)
	}

	ip, _, _ := net.SplitHostPort(r.Host)

	log.Println("Local IP: " + ip)

	if ip == "localhost" || ip == "" {
		ip = "127.0.0.1"
	}

	/* Figure out what listener this is */
	rows, err := db.Query(
			"SELECT l_id, state, cookie " +
			"FROM listeners " +
			"WHERE address = $1",
			ip)
	defer rows.Close()

	if err != nil {
		panic(err)
		return ""
	}

	for rows.Next() {
		var l_id	int
		var lstate	string
		var cookie	string

		err := rows.Scan(&l_id, &lstate, &cookie)
		if err != nil {
			log.Fatal(err)
			return ""
		}

		switch lstate {
		case "initial":
			var c http.Cookie

			/* Simple, just return a cookie, nothing else */
			c.Name = cookie
			c.Value = ap.HashIt(ap.GenPassphrase(16))
			w.Header().Set("Set-Cookie", c.String())

		case "redirect":
			if !acs_redirect(w, r) {
				/* No valid cookie, thus not a redirect */
				lstate = ""
			}

		case "relay":
			if !acs_relay(w, r) {
				/* No valid cookie, thus not a redirect */
				lstate = ""
			}
		}

		/* An actual listener */
		return lstate
	}

	/* Nothing found */
	return ""
}

func (f *ACS) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	/* Handle it or return the default page */
	s := acs_handle(w, r)

	/* Log what happened */
	log.Printf("%s %s %s %s\n", r.RemoteAddr, r.Method, r.URL, s)

	/* Nothing happened? Return default page */
	if s == "" || s == "initial" {
		if ap_defaultsite == "" {
			/* XXX: Return fake page */
			w.Write([]byte("Welcome to this website"))
		} else {
			acs_proxy(ap_defaultsite, w, r)
		}

		/* Unknown/unconfigured listener */
		if s == "" {
			s = "unknown"
		}
	}

	/* Register a hit at the ACSdb */
	var h		ap.Hit

	/* Parse the IP from the Host
	 *
	 * Go does not disclose local source IP
	 * but when operating behind a proxy
	 * it will be included in a special header
	 * or in the Host: header
	 */
	var d string
	host, ok := r.Header["LocalAddr"]
	if ok {
		d = host[0]
	} else {
		d = r.Host
	}

	d, _, _ = net.SplitHostPort(d)
	if net.ParseIP(d) != nil {
		h.Destination = d
	} else {
		h.Destination	= "0.0.0.0"
	}

	h.When		= strconv.FormatInt(time.Now().Unix(), 10)
	h.Source, _, _  = net.SplitHostPort(r.RemoteAddr)
	h.Host		= r.Host
	h.Method	= r.Method
	h.URL		= r.URL.String()
	h.Verdict	= s

	json, err := json.MarshalIndent(h, "", "\t")
	if err != nil {
		/* Should never happen, thus abort */
		panic(err)
	}

	/* Tell ACSdb we got a hit */
	_, _, _ = ask_db("/gw/hit/", string(json))
}

func pool_add(prefix string) {
	var m		ap.Result
	var p		ap.PoolAdd
	var err		error

	p.Prefix = prefix
	p.Exclude = "none"
	p.When = "2014-02-01T14:42:00Z/2017-02-01T14:42:00Z"

	json, err := json.MarshalIndent(p, "", "\t")
	if err != nil {
		/* Should never happen, thus abort */
		panic(err)
	}

	/* Ask ACSdb to add it */
	response, err, _ := ask_db("/pool/add/", string(json))

	err = jsondec(response, &m);
	if err != nil {
		log.Fatal(err)
		return
	}

	if m.Status != "ok" {
		log.Fatal("Error: " + m.Message)
		return
	}

	/* Success, add locally */
	rows, err := db.Query(
			"INSERT INTO pools " +
			"(prefix) " +
			"VALUES($1)",
			prefix)
	defer rows.Close()

	if err != nil {
		panic(err)
		return
	} else {
		log.Println("Added Pool " + prefix);
	}
}

/* Note 'type' is a golang-reserved word, hence use btype instead */
func bridge_add(identity string, btype string, options string, address string, port string) {
	var m	ap.Result
	var b	ap.BridgeAdd

	/* We don't tell the local details (address, port) to ACSdb, no need to know */
	b.Identity	= identity
	b.Type		= btype
	b.Options	= options

	json, err := json.MarshalIndent(b, "", "\t")
	if err != nil {
		/* Should never happen, thus abort */
		panic(err)
	}

	/* Ask ACSdb to add it */
	response, err, _ := ask_db("/bridge/add/", string(json))

	err = jsondec(response, &m);
	if err != nil {
		log.Fatal(err)
		return
	}

	if m.Status != "ok" {
		log.Fatal("Error: " + m.Message)
		return
	}

	/* Success, add locally */
	rows, err := db.Query(
			"INSERT INTO bridges " +
			"(identity, type, options, address, port)  " +
			"VALUES($1, $2, $3, $4, $5)",
			identity, btype, options, address, port)
	defer rows.Close()

	if err != nil {
		panic(err)
		return
	} else {
		log.Println("Added Bridge " + identity);
	}
}

/*
 * When we do not loop (--ping-once) it effectively
 * just waits for the real running process to ping
 * our DB
 */
func ping(loop bool) {
	var p ap.Ping

	p.Callback = "http://127.0.0.1:8081"
	p.Username = ag_username
	p.Password = ag_password

	json, err := json.MarshalIndent(p, "", "\t")
	if err != nil {
		/* Should never happen, thus abort */
		panic(err)
	}

	for {
		if loop {
			ask_db("/gw/ping/", string(json))
		} else {
			log.Println("Waiting for real process to ping")
		}

		/* Sleep a bit */
		time.Sleep(5 * time.Second)

		if !loop {
			log.Println("Real process should have pinged by now")
			break;
		}
	}
}

func main() {
	var db_name = "acsgw"
	var db_user = "acsgw"
	var err		error

	log.SetPrefix("acsgw: ")

	f_setup_psql	:= flag.Bool("setup-psql",	false,				"Configure database access (run as 'postgres' user)")
	f_setup_db	:= flag.Bool("setup-db",	false,				"Configure database schema")
	f_pool_add	:= flag.Bool("pool-add",	false,				"Add a Pool, arguments: prefix")
	f_bridge_add	:= flag.Bool("bridge-add",	false,				"Add a Bridge, arguments: identity, type, address, port, options")
	f_ping_once	:= flag.Bool("ping-once",	false,				"Ping the ACS Database once")

	flag.StringVar(&ap_defaultsite, "defaultsite",	"",				"URL to proxy unknown requests to (eg http://www.safdef.org) or empty for none")
	flag.StringVar(&ap_database, "database",	"http://localhost:8080",	"URL of the ACS Database")
	flag.StringVar(&ad_username, "username",	"gw1",				"Username to use")
	flag.StringVar(&ad_password, "password",	"gw1-password",			"Password to use")
	flag.Parse()

	if *f_setup_psql {
		ap.DB_setup_psql(db_name, db_user);
		return
	}

	if *f_setup_db {
		ap.DB_setup_schema(db_name, db_user, "acsgw.psql");
		return
	}

	if *f_ping_once {
		ping(false)
		return
	}

	/* Connect to the DB */
	db, err = sql.Open("postgres", "user=" + db_user + " dbname=" + db_name + " sslmode=disable")
	if err != nil {
		log.Fatal(err)
		return
	}

	defer db.Close()

	if *f_pool_add {
		if flag.NArg() != 1 {
			log.Fatal("Prefix is missing")
				return
		}

		pool_add(flag.Arg(0))
		return
	}

	if *f_bridge_add {
		if flag.NArg() < 5 {
			log.Fatal("Arguments are missing")
				return
		}

		var options = ""
		for i := 4; i < flag.NArg(); i++ {
			options += flag.Arg(i) + " "
		}

		bridge_add(flag.Arg(0), flag.Arg(1), options, flag.Arg(2), flag.Arg(3))
		return
	}

	wg := &sync.WaitGroup{}

	/* Setup a http client */
	client = &http.Client{}

	/* Setup web service and handlers */
	http.HandleFunc("/", h_root)
	http.HandleFunc("/reset/", h_reset)
	http.HandleFunc("/status/", h_status)

	http.HandleFunc("/listener/add/initial/", h_lst_add_initial)
	http.HandleFunc("/listener/add/redirect/", h_lst_add_redirect)
	http.HandleFunc("/listener/add/relay/", h_lst_add_relay)
	http.HandleFunc("/listener/remove/", h_lst_remove)

	http.HandleFunc("/block/add/", h_block_add)
	http.HandleFunc("/block/remove/", h_block_remove)

	/* Generate random username/password */
	ag_username = ap.GenPassphrase(10)
	ag_password = ap.GenPassphrase(10)

	/* Start the pinger */
	wg.Add(1)
	go func() {
		ping(true)
		wg.Done()
	}()

	/* Start APRP (gw<->db communication) */
	wg.Add(1)
	go func() {
		mux := ap.HTTP_Handler(http.DefaultServeMux, user_check, realm)
		err = http.ListenAndServe(":8081", mux)
//		err = http.ListenAndServeTLS(":8081", "cert.pem", "key.pem", mux)
		if err != nil {
			log.Fatal(err)
		}
		wg.Done()
	}()

	/* Start ACS */
	wg.Add(1)
	go func() {
		err = http.ListenAndServe(":8082", &ACS{})
		if err != nil {
			log.Fatal(err)
		}
		wg.Done()
	}()

	log.Println("Running and serving on 8081 (APRP) and ACS (8082)")
	wg.Wait()
}

