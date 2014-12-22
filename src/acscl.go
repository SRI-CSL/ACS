///usr/bin/env go run $0 $@; exit
package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	/* Own tools */
	"./ap"
)

/* Global variables */
var client *http.Client

func aplog(msg string) {
	log.Println(msg)
}

func aperr(v ...interface{}) {
	log.Println(v...)
}

/* Send a request to DDB */
func ask_host(url string, customhost string, cookies []http.Cookie, json string) (body string, err error, response *http.Response) {
	aplog("Contacting " + url)
	return ap.HTTP_Action(url, customhost, cookies, "", "", json);
}

func acs_wait(wait int, window int) {
	var S	string
	var W	string
	var R	string
	var D	string
	var d	time.Duration
	var r	int

	r = ap.RandomInt(window)

	S = strconv.Itoa(wait)
	W = strconv.Itoa(window)
	R = strconv.Itoa(r)
	D = strconv.Itoa(wait + r)

	aplog("Sleeping for the NET Wait (wait: " + S + ", window: " + W + ", rand-window: " + R + ") = " + D)
	d, _ = time.ParseDuration(D + "s")
	time.Sleep(d)
}

func main() {
	var net		ap.NET
	var body	string
	var r		*http.Response
	var port	string

	port = "80"

	log.SetPrefix("acscl: ")

	f_test_relay	:= flag.Bool(	"test-relay",	false,	"Test relay by sending a query")
	f_port		:= flag.String(	"force-port",	"",	"Force port number (useful for testing locally)")

	flag.Parse()
	if (flag.NArg() != 1) {
		aperr("The filename of a NET is required as an argument")
		return
	}

	if *f_port != "" {
		port = *f_port
	}

	file, err := ioutil.ReadFile(flag.Arg(0))
	if (err != nil) {
		aperr(err)
		return
	}

	err = json.Unmarshal(file, &net)
	if err != nil {
		aperr(err)
		return
	}

	/* Analyze the JSON when */
	if len(net.When) > 0 {
		var res		string
		var detail	string
		var t_start	string
		var t_end	string
		var t_start_	int
		var t_end_	int

		res, detail, t_start, t_end = ap.Parse_when(net.When)
		if res != "ok" {
			aperr(detail)
			return
		}

		now := time.Now()
		unx := int(now.Unix())

		t_start_, _ = strconv.Atoi(t_start)
		t_end_, _ = strconv.Atoi(t_end)

		if t_start_ > unx || t_end_ < unx {
			aperr("NET indicates it is not valid for the current time: " + net.When)
			return
		}
	}

	aplog("Performing Initial")
	body, err, r = ask_host("http://" + net.Initial + ":" + port, "", nil, "")

	/* Check HTTP code */
	if r.StatusCode != 200 {
		aperr("HTTP Status not 200 but " + strconv.Itoa(r.StatusCode))
		return
	}

        // base64(sha256(initial-address + NET.passphrase + wait + window))
        cookievalue := ap.HashIt(	net.Initial +
					net.Passphrase +
					strconv.FormatInt(int64(net.Wait), 10) +
					strconv.FormatInt(int64(net.Window), 10))

	var scookies []http.Cookie

	cookies := r.Cookies()
	for i:=0; i < len(cookies); i++ {
		var c http.Cookie

		aplog("HTTP Cookie: " + cookies[i].Name + ", Value: " + cookies[i].Value)

		c.Name = cookies[i].Name;
		c.Value = cookievalue

		scookies = append(scookies, c)
	}

	/* Are there any cookies at all? */
	if len(scookies) == 0 {
		aperr("No Cookie received from Initial contact")
		return
	}

	acs_wait(net.Wait, net.Window)

	aplog("Performing Redirect")
	body, err, r = ask_host("http://" + net.Redirect + ":" + port, "", scookies, "")

	/* Check HTTP code */
	if r.StatusCode != 200 {
		aperr("HTTP Status not 200 but " + strconv.Itoa(r.StatusCode))
	}

	relays := ap.UnBase64(body)

	/* XXX: De-steg */

	log.Println(	"Please Relay through:\n" +
			"8<-------------------------\n" +
			string(relays) + "\n" +
			"-------------------------->8\n")

	if *f_test_relay {
		var rels []ap.Bridge
		aplog("Testing relay queries")

		err := json.Unmarshal(relays, &rels)
		if err != nil {
			aperr(err)
			return
		}

		for i:=0; i < len(rels); i++ {
			var scookies []http.Cookie
			var c http.Cookie

			port = strconv.FormatInt(int64(rels[i].Port), 10)

			aplog("Host: " + rels[i].Address + ", port " + port)

			j := strings.Index(rels[i].Cookie, "=")
			if j < 0 {
				aperr("Cookie invalid? Skipping (" + rels[i].Cookie + ")")
				continue
			}

			c.Name, c.Value = rels[i].Cookie[:j], rels[i].Cookie[j+1:]

			scookies = append(scookies, c)

			if *f_port != "" {
				port = *f_port
				aplog("Forcing port to " + port)
			}


			body, err, r = ask_host("http://" + rels[i].Address + ":" + port, "", scookies, "")
		}
	}

	aplog("All done")
}

