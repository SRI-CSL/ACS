package ap

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math"
	"net"
	"net/http"
        "strings"
	"strconv"
        "time"
)

type Result struct {
	Status		string		`json:"status"`
	Message		string		`json:"message"`
}

type Ping struct {
	Callback	string		`json:"callback"`
	Username	string		`json:"username"`
	Password	string		`json:"password"`
}

type Hit struct {
	When		string		`json:"when"`
	Source		string		`json:"src"`
	Destination	string		`json:"dst"`
	Host		string		`json:"host"`
	Method		string		`json:"method"`
	URL		string		`json:"url"`
	UserAgent	string		`json:"useragent"`
	Verdict		string		`json:"verdict"`
}

type NET struct {
	Initial		string		`json:"initial"`
	Redirect	string		`json:"redirect"`
	Wait		int		`json:"wait"`
	Window		int		`json:"window"`
	Passphrase	string		`json:"password"`
	When		string		`json:"when"`
}

type StatusPools struct {
	Number		int		`json:"number"`
	Tot_addresses	int		`json:"tot_addresses"`
}

type StatusListeners struct {
	Initials	int		`json:"initials"`
	Redirects	int		`json:"redirects"`
	Relays		int		`json:"relays"`
}

type Status struct {
	Pools		StatusPools	`json:"pools"`
	Listeners	StatusListeners	`json:"listeners"`
}

type GatewayOp struct {
	Username	string		`json:"username"`
	Password	string		`json:"password"`
}

type PoolAdd struct {
	Prefix		string		`json:"prefix"`
	Exclude		string		`json:"exclude"`
	When		string		`json:"when"`
}

type Prefix struct {
	Prefix		string		`json:"prefix"`
}

type Id struct {
	Id		string		`json:"id"`
}

type Bridge struct {
	Address		string		`json:"address"`
	Port		int		`json:"port"`
	Cookie		string		`json:"cookie"`
	Type		string		`json:"type"`
	Options		string		`json:"options"`
}

type BridgeAdd struct {
	Identity	string		`json:"id"`
	Type		string		`json:"type"`
	Options		string		`json:"options"`
}

type ListenerAddInitial struct {
	Address		string		`json:"address"`
	Port		int		`json:"port"`
	Cookie		string		`json:"cookie"`
}

type ListenerAddRedirect struct {
	Address		string		`json:"address"`
	Port		int		`json:"port"`
	Cookie		string		`json:"cookie"`

	/* The Cookievalue */
	FullCookie	string		`json:"fullcookie"`

	Bridges		string		`json:"bridges"`
}

type ListenerAddRelay struct {
	Address		string		`json:"address"`
	Port		int		`json:"port"`
	Cookie		string		`json:"cookie"`

	/* The cookie to get to this one */
	FullCookie	string		`json:"fullcookie"`

	/* The bridge to forward to when the FullCookie matches */
	Identity	string		`json:"br_identity"`
}

func Exp(x int, y int) (n int) {
	return int(math.Pow(float64(x), float64(y)))
}

func GenPassphrase(len int) (pass string) {
	b := make([]byte, len)
	_, err := rand.Read(b)
	if err != nil {
		log.Fatal(err)
		return ""
	}

	pass = ""

	for i:=0; i < len; i++ {
		pass += fmt.Sprintf("%02x", b[i])
	}

	return pass
}

func UnBase64(b64 string) (str []byte) {
	str, _ = base64.URLEncoding.DecodeString(b64)
	return str
}

func Base64b(data []byte) (b64 string) {
	return base64.URLEncoding.EncodeToString(data)
}

func Base64(data string) (b64 string) {
	return Base64b([]byte(data))
}

func HashIt(data string) (h string) {
	hash := sha256.New()
	io.WriteString(hash, data)
	return Base64b(hash.Sum(nil))
}

func RandomInt(max int) (rnd int) {
	len := 4;

	b := make([]byte, len)
	_, err := rand.Read(b)
	if err != nil {
		panic(err)
		return 0
	}

	rnd = 0
	for i:=0; i < len; i++ {
		rnd <<= 8
		rnd += int(b[i])
	}

	return rnd % max
}

func Parse_when(when string) (ret string, detail string, t_start string, t_end string) {
	var err		error
	var t		time.Time

	times := strings.SplitN(when, "/", 2)

	if len(times) > 2 {
		return "error", "when has too many components", "0", "0"
	}

	if len(times) >= 1 {
		t, err = time.Parse(time.RFC3339, times[0])
		if err != nil {
			return "error", "when first unparseable", "0", "0"
		}

		t_start = strconv.FormatInt(t.Unix(), 10)
	}

	if len(times) == 2 {
		t, err = time.Parse(time.RFC3339, times[1])
		if err != nil {
			return "error", "when end unparseable", "0", "0"
		}

		t_end = strconv.FormatInt(t.Unix(), 10)
	}

	return "ok", detail, t_start, t_end
}

type HTTPAuth_Checker func(user string, pass string, ip string) int

func HTTPAuth_Check(r *http.Request, check HTTPAuth_Checker) (int, string) {
	var usr_id = 0
	var username = "_invalid_"

	s := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
	if len(s) != 2 {
		return 0, username
	}

	b, err := base64.StdEncoding.DecodeString(s[1])
	if err != nil {
		return 0, username
	}

	pair := strings.SplitN(string(b), ":", 2)
	if len(pair) != 2 {
		return 0, username
	}

	username = pair[0]

	ip, _, _ := net.SplitHostPort(r.RemoteAddr)

	usr_id = check(username, pair[1], ip)

	return usr_id, username
}

func HTTP_Handler(handler http.Handler, check HTTPAuth_Checker, realm string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		usr_id, username := HTTPAuth_Check(r, check)

		if usr_id == 0 && len(realm) != 0 {
			log.Printf("%s %d %s %s %s\n", r.RemoteAddr, 0, "-", r.Method, r.URL)
			w.Header().Set("WWW-Authenticate", `Basic realm="` + realm + `"`)
			w.WriteHeader(http.StatusUnauthorized)
			w.Write([]byte("401 Unauthorized\n"))
			return
		}

		/* Log the request along with a username */
		/* XXX: Escape properly */
		/* log.Fprintf(os.Stdout, ...) */
		log.Printf("%s %d %s %s %s\n", r.RemoteAddr, usr_id, username, r.Method, r.URL)
		handler.ServeHTTP(w, r)
	})
}

func HTTPAuth_Basic(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

/* Calls the HTTP URL and parses answer */
func HTTP_Action(url string, customhost string, cookies []http.Cookie, username string, password string, json string) (body string, err error, response *http.Response) {
	var client	*http.Client
	var b		[]byte;
	var request	*http.Request;

	if len(json) != 0  {
		post_data := strings.NewReader(json)
		request, err = http.NewRequest("POST", url, post_data)
	} else {
		request, err = http.NewRequest("GET", url, nil)
	}

	if err != nil {
		return "", err, nil
	}

	if customhost != "" {
		request.Header.Add("Host", customhost)
	}

	if cookies != nil {
		for i:=0; i < len(cookies); i++ {
			request.AddCookie(&cookies[i])
		}
	}

	if username != "" {
		request.Header.Add("Authorization", "Basic " + HTTPAuth_Basic(username, password))
	}

	/* JumpBox should be used to solve any problems with parrotted HTTP */
	request.Header.Add("User-Agent", "ACS")

	client = &http.Client{}
	response, err = client.Do(request)

	if err != nil {
		log.Println(err)
		return "", err, response
	}

	if response.StatusCode != 200 {
		log.Println("HTTP Error: " + response.Status)
		return "Status not 200", nil, nil
		/* XXX: return error */
	}

	b, err = ioutil.ReadAll(response.Body)

	response.Body.Close()

	log.Print("8<---------------\n" + string(b) + "\n---------------->8\n")

	return string(b), nil, response
}

