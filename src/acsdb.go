///usr/bin/env go run $0 $@; exit
package main

// ACSgw - ACS DataBase

import (
	_ "github.com/lib/pq"
//	"bytes"
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net"
	"net/http"
//	"strings"
	"strconv"
//	"time"

	/* Own tools */
	"./ap"
)

/* Global variables */
var db *sql.DB
var tool_title = "ACSdb - ACS DataBase"
var realm = "ACS"

/* http.Request r.URL.Path */

func user_check(user string, pass string, ip string) int {
	var usr_id int

	/* Check if the user/pass combo is valid and select the gateway */
	rows, err := db.Query(
			"SELECT usr_id " +
			"FROM users " +
			"WHERE username = $1 AND password = $2",
			user, pass)
	defer rows.Close()

	if err != nil {
		panic(err)
		return 0
	}

	for rows.Next() {
		err := rows.Scan(&usr_id)
		if err != nil {
			log.Fatal(err)
		}
		return usr_id
	}

	return 0
}

func getparams(w http.ResponseWriter, r *http.Request, m interface{}) (ret bool, usr_id int) {

	usr_id, _ = ap.HTTPAuth_Check(r, user_check)

	if usr_id == 0 {
		w.Header().Set("WWW-Authenticate", "Basic realm=\"" + realm + "\"")
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte("401 Unauthorized\n"))
		return
	}

	rows, err := db.Query(
			"UPDATE users " +
			"SET lastrequest = NOW() " +
			"WHERE usr_id = $1",
			usr_id)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	}

	if r.Method == "GET" {
		/* Nothing else to do */

	} else if r.Method == "POST" {
		dec := json.NewDecoder(r.Body)

		/* Expect multiple objects, even if we only want one */
		for {
			err := dec.Decode(&m)
			if err == io.EOF {
				break;
			} else if err != nil {
				result(w, "error", err.Error())
				return false, usr_id
			}
		}
	} else {
		h_error(w, r, http.StatusMethodNotAllowed)
		return false, 0
	}

	return true, usr_id
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

/* Send a request to DDB */
func ask_gw(usr_id int, url string, v interface{}) (body string, err error, response *http.Response) {
	var cb_url string
	var cb_username string
	var cb_password string

	log.Println(url)

	rows, err := db.Query(
			"SELECT cb_url, cb_username, cb_password " +
			"FROM users " +
			"WHERE usr_id = $1",
			usr_id)
	defer rows.Close()

	if err != nil {
		panic(err)
		return "", err, nil
	}

	for rows.Next() {
		err = rows.Scan(&cb_url, &cb_username, &cb_password)
		if err != nil {
			log.Fatal(err)
			return "", err, nil
		}

		json, err := json.MarshalIndent(v, "", "\t")
		if err != nil {
			/* Should never happen, thus abort */
			panic(err)
			return "", err, nil
		}

		return ap.HTTP_Action(cb_url + url, "", nil, cb_username, cb_password, string(json));
	}

	return "", err, nil
}

func h_error(w http.ResponseWriter, r *http.Request, status int) {
	w.WriteHeader(status)
	if status == http.StatusNotFound {
		fmt.Fprint(w, "custom 404")
	}
}

func h_root(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		h_error(w, r, http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, tool_title)
}

func status_tot(table string) (int) {
	var tot int;

	rows, err := db.Query(
			"SELECT COUNT(*) FROM " + table)
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
			"SELECT SUM(2 ^ ((CASE WHEN family(prefix) = 6 THEN 128 ELSE 32 END) - MASKLEN(prefix))) " +
			"FROM pools")
	defer rows.Close()

	if err != nil {
		panic(err)
		return 0
	}

	for rows.Next() {
		err := rows.Scan(&tot)
		if err != nil {
			panic(err)
		}

		return tot
	}

	return 0
}

func h_status(w http.ResponseWriter, r *http.Request) {
	pool_num	:= status_tot("pools")
	pool_addr	:= status_tot_addr()
	lst_initials	:= status_tot("initials")
	lst_redirects	:= status_tot("redirects")
	lst_relays	:= status_tot("relays")

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

func h_gw_hit(w http.ResponseWriter, r *http.Request) {
	var m ap.Hit

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		result(w, "err", "Auth")
		return
	}

	rows, err := db.Query(
			"INSERT INTO hits " +
			"(usr_id, entered, src, dst, host, method, url, useragent, verdict) " +
			"VALUES($1, to_timestamp($2), $3, $4, $5, $6, $7, $8, $9)",
			usr_id, m.When, m.Source, m.Destination, m.Host, m.Method, m.URL, m.UserAgent, m.Verdict)
	if (rows != nil) {
		rows.Close()
	}

	if err != nil {
		log.Println(err)
		result(w, "error", err.Error())
		return
	}

	result(w, "ok", "Ack")
}

func h_gw_ping(w http.ResponseWriter, r *http.Request) {
	var m ap.Ping

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		result(w, "err", "Auth")
		return
	}

	rows, err := db.Query(
			"UPDATE users " +
			"SET cb_url = $1, cb_username = $2, cb_password = $3 " +
			"WHERE usr_id = $4",
			m.Callback, m.Username, m.Password, usr_id)
	rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	}

	/*
	 * Note that Ping is just a 'bonus' every request
	 * updates users.lastrequest from which we know
	 * that the gateway can talk to us
	 */
	result(w, "ok", "Pong")
}

func h_pool_add(w http.ResponseWriter, r *http.Request) {
	var m		ap.PoolAdd
	var t_start	string
	var t_end	string
	var err		error

	t_start = ""
	t_end = ""

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	/* Analyze the JSON when */
	if len(m.When) > 0 {
		var res string
		var detail string

		res, detail, t_start, t_end = ap.Parse_when(m.When)
		if res != "ok" {
			result(w, res, detail)
			return
		}
	}

	_, ipnet, err := net.ParseCIDR(m.Prefix)
	if err != nil {
		result(w, "error", err.Error())
		return
	}

	msk := ipnet.Mask
	size, bits := msk.Size()
	totaddr := ap.Exp(2, bits - size)

	rows, err := db.Query(
			"INSERT INTO pools " +
			"(usr_id, prefix, totaddr, exclude, min_active, max_active) " +
			"VALUES($1, $2, $3, $4, to_timestamp($5), to_timestamp($6))",
			usr_id, m.Prefix, totaddr, m.Exclude, t_start, t_end)

	if err != nil {
		result(w, "error", err.Error())
	} else {
		result(w, "ok", "Added " + m.Prefix);
	}

	if rows != nil {
		rows.Close()
	}
}

func h_pool_remove(w http.ResponseWriter, r *http.Request) {
	var m ap.Prefix

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	rows, err := db.Query(
			"DELETE FROM pools " +
			"WHERE usr_id = $1 AND prefix = $2",
			usr_id, m.Prefix)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	} else {
		result(w, "ok", "Removed " + m.Prefix);
	}
}

func h_pool_enable(w http.ResponseWriter, r *http.Request) {
	var m ap.Prefix

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	rows, err := db.Query(
			"UPDATE pools " +
			"SET enabled = true " +
			"WHERE usr_id = $1 AND prefix = $2",
			usr_id, m.Prefix)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	} else {
		result(w, "ok", "Enabled " + m.Prefix);
	}
}

func h_pool_disable(w http.ResponseWriter, r *http.Request) {
	var m ap.Prefix

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	rows, err := db.Query(
			"UPDATE pools " +
			"SET enabled = false " +
			"WHERE usr_id = $1 AND prefix = $2",
			usr_id, m.Prefix)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	} else {
		result(w, "ok", "Disabled " + m.Prefix);
	}
}

func h_bridge_add(w http.ResponseWriter, r *http.Request) {
	var m ap.BridgeAdd

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	rows, err := db.Query(
			"INSERT INTO bridges " +
			"(usr_id, identity, type, options) " +
			"VALUES($1, $2, $3, $4)",
			usr_id, m.Identity, m.Type, m.Options)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	} else {
		result(w, "ok", "Bridge " + m.Type + " added");
	}
}

func h_bridge_remove(w http.ResponseWriter, r *http.Request) {
	var m ap.Id
	var usr_id int

	ret, usr_id := getparams(w, r, &m)
	if ret == false {
		return
	}

	rows, err := db.Query(
			"DELETE FROM bridges " +
			"WHERE usr_id = $1 AND br_id = $2",
			usr_id, m.Id)
	defer rows.Close()

	if err != nil {
		result(w, "error", err.Error())
		return
	} else {
		result(w, "ok", "Removed " + m.Id);
	}
}

/* Pick a new random address */
func pick_random_addr() (gw_id int, pool_id int, address string) {
	rows, err := db.Query(
			"SELECT usr_id, pool_id, " +
			"host(prefix + trunc(RANDOM() * totaddr + 1)::int) " +
			"FROM pools " +
			"WHERE enabled = true " +
			"AND min_active < NOW() " +
			"AND max_active > NOW() " +
			"ORDER BY RANDOM() limit 1")
	defer rows.Close()

	if err != nil {
		panic(err)
		return -1, -1, ""
	}

	for rows.Next() {
		err := rows.Scan(&gw_id, &pool_id, &address)
		if err != nil {
			panic(err)
		}

		return gw_id, pool_id, address
	}

	return -1, -1, ""
}

func pick_random_addr_type(lstate string) (gw_id int, l_id int, address string) {
	/* Try to get a random address that matches the lstate or is unused */
	for i := 0; i < 4042; i++ {
		gw_id, pool_id, address := pick_random_addr()

		if pool_id < 0 {
			log.Fatal("No Addresses")
			return -1, -1, ""
		}

		rows, err := db.Query(
			"SELECT l_id, state " +
			"FROM listeners " +
			"WHERE address = $1",
			address)
		defer rows.Close()

		if err != nil {
			log.Fatal(err)
			return -1, -1, ""
		}

		for rows.Next() {
			var state string

			err := rows.Scan(&l_id, &state)
			if err != nil {
				panic(err)
				return -1, -1, ""
			}

			log.Println("state = " + state + ", lstate = " + lstate)

			if state != lstate {
				/* Try again */
				pool_id = -1
				break;
			}

			/* Got it already */
			return gw_id, l_id, address
		}
		rows.Close()

		/*
		 * Try again as the listener was already
		 * used for a different state
		 */
		if pool_id == -1 {
			continue
		}

		/* Insert into the database */
		rows, err = db.Query(
			"INSERT INTO listeners " +
			"(pool_id, address, state) " +
			"VALUES($1, $2, $3) " +
			"RETURNING l_id", 
			pool_id, address, lstate)
		defer rows.Close()

		if err != nil {
			log.Fatal(err)
			return -1, -1, ""
		}

		defer rows.Close()
		for rows.Next() {
			var l_id int

			err := rows.Scan(&l_id)
			if err != nil {
				panic(err)
				return -1, -1, ""
			}

			/* Got it */	
			return gw_id, l_id, address
		}
	}

	return -1, -1, ""
}

func randomcookiename() (cookie string) {

	names := []string{
		"sid",
		"ASPSESSION",
		"SESSION",
		"PHPSESSION",

		/*
		 * Google Cookie names
		 * https://developers.google.com/analytics/devguides/collection/analyticsjs/cookie-usage
		 *
		 * These are also presented for 'local' GA instances that avoid the google host for tracking
		 */
		"_ga",
		"_gat",
		"__utma",
		"__utmt",
		"__utmb",
		"__utmc",
		"__utmz",
		"__utmv",
		}

	return names[ap.RandomInt(len(names))]
}

func ticket_create() (ticket string) {
	var t ap.NET

	gw_id_ini, l_id_ini, addr_ini := pick_random_addr_type("initial")
	gw_id_red, l_id_red, addr_red := pick_random_addr_type("redirect")
	gw_id_rel, l_id_rel, addr_rel := pick_random_addr_type("relay")

	t.Initial = addr_ini
	t.Redirect = addr_red
	t.Wait = 10
	t.Window = 10

	/* The NET passphrase is used for redirect NET ownership proof + decoding result */
	t.Passphrase = ap.GenPassphrase(16)

	rows, err := db.Query(
			"INSERT INTO tickets " +
			"(initial, redirect, relay, wait, waitwindow, passphrase) " +
			"VALUES($1, $2, $3, $4, $5, $6)",
			l_id_ini, l_id_red, l_id_rel, t.Wait, t.Window, t.Passphrase)
	defer rows.Close()

	if err != nil {
		log.Fatal(err)
		return ""
	}

	/* Inform the ACSgw's */
	var mini ap.ListenerAddInitial
	mini.Address	= addr_ini
	mini.Port	= 80
	mini.Cookie	= randomcookiename()
	ask_gw(gw_id_ini, "/listener/add/initial/", mini)
	/* XXX Handle failures */


	/* Which bridges are available on this relay? */
	rows, err = db.Query(
			"SELECT identity, type, options " +
			"FROM bridges " +
			"WHERE usr_id = $1",
			gw_id_rel)
	defer rows.Close()

	if err != nil {
		panic(err)
		return ""
	}

	var Bridges	[]ap.Bridge

	for rows.Next() {
		var b		ap.Bridge
		var br_identity	string
		var br_type	string
		var br_options	string

		err := rows.Scan(&br_identity, &br_type, &br_options)
		if err != nil {
			log.Fatal(err)
			return ""
		}

		/* Each bridge gets their own passphrase, thus allowing multiple on the same IP */
		b.Address = addr_rel
		b.Port = 80
		b.Cookie = randomcookiename() + "=" + ap.GenPassphrase(16)
		b.Type = br_type
		b.Options = br_options

		Bridges = append(Bridges, b)

		/* Tell the relay about this bridge being given out */
		var mrel ap.ListenerAddRelay
		mrel.Address	= addr_rel
		mrel.Port	= 80
		mrel.Cookie	= randomcookiename()
		mrel.FullCookie	= b.Cookie
		mrel.Identity	= br_identity

		ask_gw(gw_id_rel, "/listener/add/relay/", mrel)
		/* XXX Handle failures */
	}

	/* Encode the Bridges as JSON */
	bridges , _ := json.MarshalIndent(Bridges, "", "\t")

	/* XXX: Apply JEL or other Stegographer (using NET.passphrase as a key) */

	var mred ap.ListenerAddRedirect
	mred.Address	= addr_red
	mred.Port	= 80
	mred.Cookie	= randomcookiename()

	// base64(sha256(initial-address + NET.passphrase + wait + window))
	mred.FullCookie	= mini.Cookie + "=" +
			  ap.HashIt(	addr_ini +
					t.Passphrase +
					strconv.FormatInt(int64(t.Wait), 10) +
					strconv.FormatInt(int64(t.Window), 10))

	/* Transport them in base64, the redirect does thus not know final details */
	mred.Bridges = ap.Base64b(bridges)

	ask_gw(gw_id_red, "/listener/add/redirect/", mred)
	/* XXX Handle failures */

	/* Return the final ticket */
	json, err := json.MarshalIndent(t, "", "\t")
	if err != nil {
		/* Should never happen, thus abort */
		log.Fatal(err)
	}

	return string(json)
}

func h_tickets_fetch(w http.ResponseWriter, r *http.Request) {
	var m ap.Id

	ret, _ := getparams(w, r, &m)
	if ret == false {
		return
	}

	ticket := ticket_create()

	result(w, "ok", ticket)
}

func user_add(username string, password string) {
	rows, err := db.Query(
			"INSERT INTO users " +
			"(username, password) " +
			"VALUES($1, $2)",
			username, password)
	defer rows.Close()

	if err != nil {
		log.Fatal(err)
		return
	} else {
		log.Println("Added " + username);
	}
}

func user_remove(username string) {
	var m		ap.GatewayOp

	rows, err := db.Query(
			"DELETE FROM users WHERE " +
			"username = $1 ",
			m.Username)
	defer rows.Close()

	if err != nil {
		log.Fatal(err)
		return
	} else {
		log.Println("Removed " + m.Username);
	}
}

func main() {
	var db_name = "acsdb"
	var db_user = "acsdb"
	var err error

	log.SetPrefix("acsdb: ")

	f_setup_psql	:= flag.Bool("setup-psql",	false, "Configure database access (run as 'postgres' user)")
	f_setup_db	:= flag.Bool("setup-db",	false, "Configure database schema")
	f_user_add	:= flag.Bool("user-add",	false, "Add a User (or Gateway), arguments: username + password")
	f_user_remove	:= flag.Bool("user-remove",	false, "Remove a User (or Gateway), argument: username")
	f_ticket_create	:= flag.Bool("ticket-create",	false, "Create a ticket, optional arguments: filename for storing NET")
	flag.Parse()

	if *f_setup_psql {
		log.Println("SETUP DB")
		ap.DB_setup_psql(db_name, db_user);
		return
	}

	if *f_setup_db {
		ap.DB_setup_schema(db_name, db_user, "acsdb.psql");
		return
	}

	/* Connect to the DB */
	db, err = sql.Open("postgres", "user=" + db_user + " dbname=" + db_name + " sslmode=disable")
	if err != nil {
		log.Fatal(err)
		return
	}

	defer db.Close()

	if *f_user_add {
		if flag.NArg() != 2 {
			log.Fatal("Username/password are missing")
			return
		}

		user_add(flag.Arg(0), flag.Arg(1));
		return
	}

	if *f_user_remove {
		if flag.NArg() != 1 {
			log.Fatal("Username is missing")
			return
		}

		user_remove(flag.Arg(0));
		return
	}

	if *f_ticket_create {
		if flag.NArg() > 1 {
			log.Fatal("Only an optional filename arguments can be given")
			return
		}

		ticket := ticket_create()
		if flag.NArg() == 0 {
			log.Println("8<------------------\n" + ticket + "\n------------------>8\n")
		} else {
			ioutil.WriteFile(flag.Arg(0), []byte(ticket + "\n"), 0600)
		}
		return
	}

	/* Setup web service and handlers */
	http.HandleFunc("/", h_root)
	http.HandleFunc("/status/", h_status)

	http.HandleFunc("/gw/hit/", h_gw_hit)
	http.HandleFunc("/gw/ping/", h_gw_ping)

	http.HandleFunc("/pool/add/", h_pool_add)
	http.HandleFunc("/pool/remove/", h_pool_remove)
	http.HandleFunc("/pool/enable/", h_pool_enable)
	http.HandleFunc("/pool/disable/", h_pool_disable)

	http.HandleFunc("/bridge/add/", h_bridge_add)
	http.HandleFunc("/bridge/remove/", h_bridge_remove)

	http.HandleFunc("/tickets/fetch/", h_tickets_fetch)

	log.Println("Running and serving on 8080")
	mux := ap.HTTP_Handler(http.DefaultServeMux, user_check, realm)
	err = http.ListenAndServe(":8080", mux);
//	err = http.ListenAndServeTLS(":8443", "cert.pem", "key.pem", mux)
	if err != nil {
		log.Fatal(err)
	}
}

