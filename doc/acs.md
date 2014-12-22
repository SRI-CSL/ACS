# Address Pools

Address Pools comprised of two separate, but related, protocols:
 * ACS - Addresspools Change Signaling
 * APRP - Address Pools Registration Protocol

ACS is what the user sees and uses while APRP happens in the background
between the servers that provide the ACS service.

## Components and Terms

There are few components involved in Address Pools, the functions
and roles of these are explained below.

### ACS Database (ACSdb)

The ACS Database is the coordinator. It distributes to the Gateways
the details that they have to listen to.

ACSdb might be 1 host (be that virtual or physical) but can be multiple
too. It is the responsibility of the backend-database (eg PostgreSQL)
that the database the ACSdb uses is synchronized.

As such the 'db' hostlabel below will be multiple A/AAAA records and
thus will be spread over db1 + db2 and optionally more.

Queries will be send to either randomly, the client will failover to the
alternate addresses where needed. As such there is no master/slave, they
are all master.

All state (except connections, which are short-lived)) are kept in the
SQL database.

### ACS Gateway (ACSgw)

The Defiance Gateway hosts an Apache or other webserver for performing
ACS against. It also acts as a relay to various bridges.

These bridges can be either StegoTorus (HTTP based), Tor (direct) or
others when we defined them.

Typically there will be at least 3 physically distinct ACSgw instances,
thus having 3 completely distinct Address Pools.

### ACS Client (ACScl)

And ACS client is anything that can perform ACS.

There are two known implementations:
 - JumpBox - Webbrowser based plugin that leverages JumpBox connections
 - acscl.go - Simple Go program

### Network Entry Ticket (NET)

A NET has the following structure:

{
	"initial":	"192.0.2.1",
	"redirect":	"192.0.2.2",
	"wait":		10,
	"window":	30,
	"passphrase":	"3c4e53beaedbebbda142",
	"when":		"2014-02-01T14:42:00Z/2017-02-01T14:42:00Z"
}

"initial" and "redirect" indicate which IPs or hostnames are used for
these queries. They can optionally even include a path to make them more
unique. They are always http based due to the problems with certificates.

The wait + (0 till window) cannot overlap with values from another NET
with the same initial and redirect. Thus they have to be generated
carefully.

Typically wait/window will have to be in the multi-minute range for this
to work properly. Also because an adversary could otherwise just slow
down requests a few seconds.

The NET passphrase is used for authenticating the ACS requests and is
randomly generated.

The "when" parameter indicates when this NET is valid and is supplied optionally.

## Protocols

### Address Pools Registration Protocol (APRP)

APRP messages are send using standard HTTP POST messages to the URLs
specified below. Note that indeed both ACSdb and ACSgw thus have a running
webserver, ACSdb will be standalone (JumpBox style) while ACSgw is typically
put behind a Apache or NGINX proxy.

There is no persistent connection to maintain between the hosts, though
HTTP KeepAlive and Pipelining are recommended.

The authentication is based on the source IP address as these will be
unique per instance.

HTTPS could be used, but as we run the underlying network over a
encrypting VPN (SSH tunnels between the milkmachines) there is no need
for more security. In theory an adversary should never have access to
these nodes (if they do we have worse problems).

#### Request Response

All POST requests answer with a result object:
{
	"status":	"ok|error",
	"message":	"All okay|this or that went wrong",
}

When for instance an /add/ is repeated (which happens when ACSdb does a
full-resync), a successive /add/ is ignored and accepted.
Similar for /remove/, removing something again is a successful query.
For logging reasons "message" will contain this status though.

#### Special Queries

##### Status Query

A special query is the Status Query, it performs a:
GET http://acsgw/status/

at which ACSgw will respond with:

{
	"version":			"git-hash",
	"running-since":		12345678,
	"pools":
	{
		"number":		1,
		"tot_addresses":	256
	},
	"blocks":
	{
		"number":		3,
		tot_addresses":		1024
	},
	"bridges":
	{
		"number":		1
	},
	"listeners":
	{
		"initials":		5,
		"redirects":		5,
		"relays":		5
	}
}

This allows ACSdb to determine if the ACSgw is in sync.
If a certain section has a wrong count it can issue a /reset/

##### Ping Query

This query is used by ACSgw to inform the ACSdb of it's current location
and to inform it that it is still alive.

http://acsdb/ping/
{
	"callback":	"http://192.0.2.1:8081/",
	"username":	"username",
	"password":	"password",
}

The username/password is chosen randomly at startup of acsgw, hence a restart
of the ACSgw causes these values to change.

##### Reset Query

This query is used when an inconsistency between what ACSdb thinks should
be and what a ACSgw thinks is. This is determined with the above "Status
Query".

http://acsgw/reset/
{
	"what":		"all|pools|blocks|bridges|listeners",
	"phase":	"",
}

Depending on the "what" those sections are cleaned out.

In case of pools and bridges the ACSgw will resend them to ACSdb which in turn
will have cleared them out at the point it send this reset.

For the others ACSgw will clean those tables till it gets new information
from ACSdb (which is authoritive for that data).

To avoid a data-race the procedure is:
db: pause outbound updates
db: http://acsgw/reset/
gw: start timer (10s) for stopping update sending
gw: clean out all relevant tables
gw: send 'ok' to /reset/ query
db: start timer (60s) for unpausing outbound updates
gw: timeout -> send pools/bridges if they where reset
db: timeout -> resume outbound updates

[ Instead of timers, trigger the /reset/ url in phases? ]

##### NET Query

A "GET http://acsdb/net/fetch/" will return a NET object as described
above. This call is usually made by a DEFIANCE Freedom Factory.

#### Address Pools

Address Pools are the core of APRP.

##### Pool Add

When adding an Address Pool to a ACSgw it registers it to ACSdb:

http://acsdb/pool/add/

{
	"prefix":	"192.0.2.0/24",
	"exclude":	"none|edges",
	"when":		"iso8601",
}

###### Pool Removal, Disable, Enable

One can remove or temporary disable an Address Pool by having ACSgw send
to ACSdb:

http://acsdb/pool/{remove|disable|enable}/
{
	"prefix":	"192.0.2.0/24",
}

#### Bridges

##### Bridge Add

When adding a Bridge to a ACSgw, it is sent to the ACSdb using:

http://acsdb/bridge/add/
{
	"identity":	"bigbridge",
	"type":		"http",
	"options":	"options"
}

or for a direct Tor bridge:

{
	"identity"	"torbridge",
	"type":		"tor",
	"options":	""
}

The Bridge Identity given is local to the ACSgw and used
to indicate back to the ACSgw which bridge is selected.

##### Bridge Removal

When a Bridge is removed, ACSgw notifies ACSdb using:

http://acsdb/bridge/remove/
{
	"identity":	"torbridge"
}

#### Listeners

When a new NET is created, we create or pick listeners for it.
ACSdb tells each ACSgw what to do.

##### Listener Add

Listeners are added using the /listener/add/{type}/ URL.

##### Listener Add Initial

http://acsgw/listener/add/initial/
{
	"address":		"192.0.2.1",
	"port":			80,
	"cookie":		"PHPSESSION"
}

A address/port/hostname combo has to be unique.

Typically he "hostname" will match the IP address as we do not have
hostnames for all IP addresses.

##### Listener Add Redirect

http://acsgw/listener/add/redirect/
{
	"address":	"192.0.2.2",
	"cookie":	"PHPSESSION",
	"fullcookie":	"SID=fZ4p5q6giv81oF9TbWjnYnPe00ftIHSn9lPuNN-qXmU=",
	"bridges":	"base64-encoded json bridges",
}

The bridges string contains:
[
	{
		"address":	"192.0.2.3",
		"port":		"80",
		"cookie":	"SESSION=4a7f9bd0a13d9e9533ec464b63fabebc",
		"type":		"http",
		"options":	"options-string"
	},
	{
		"address":	"192.0.2.3",
		"port":		"8080",
		"type":		"tor",
		"options":	""
	},
}

This string can be encrypted inside stegonagrophy using the NET password.
The ACSgw that functions as a redirect gateway does need to know the content.

"cookie" is used only for http based algorithms where the relay
phase goes through ACSgw and we can inspect the HTTP query checking for
that cookiename and matching up with the value given.

"options" contains all optional fields that depend on the "type" of the
bridge.

##### Listener Add Relay

http://acsgw/listener/add/relay/
{
	"address":	"192.0.2.3",
	"port"		"80",
	"fullcookie"	"COOKIENAME=COOKIEVALUE",
	"identity":	"bigbridge"
}

"identity" is the ACSgw-local Bridge Identity, this basically tells
to pass on the connection directly.
  
The "httpcookie" field is only present for bridges of type "http"
and is used to verify that the user was able to perform ACS Redirect
which returns that value to be compared against.

#### Logging and ACLs

ACSdb manages an acceptance list which it stores as an ACL.
For queries not in the ACL per default they are all logged by ACSgw to ACSdb.

##### Logging

Unless a request is considered "good" we log a query with:

http://acsdb/gw/hit/
{
	"when":		"1418836319",
	"src":		"192.0.2.42",
	"dst":		"192.0.2.1",
	"host":		"www.example.com",
	"method":	"GET|POST|...",
	"url":		"/the/url/",
	"useragent":	"ACS-Client/1.0",
	"verdict":	"initial|relay|redirect|unknown",
}

We ignore source ports as they would just add insignificant entropy.

ACSgw aggregates the log entries and flushes them every minute, this way a
block will be distributed quickly enough but we do not log every query
hitting the server.

Note that verdict cannot be 'redirect' as we can verify that the initial
happened at ACSgw already; if that is the case we do not log the query.
Relay in HTTP mode has the same property, but relay-direct mode we
cannot know if it is a good query or not, hence the aggregation so that
we can count the number of connections.

##### ACL Add

http://acsgw/acl/add/
{
	"prefix":	"192.0.2.0/24",
	"verdict":	"accept|block|ignore|drop",
}

The verdict is either 'accept' to always accept packets from this prefix
(useful for more specifics and the default), 'block' to block, but log
requests from the given prefix, 'ignore' for ignoring the requests
(letting apache handle it) and drop, for not giving a response at all.

##### ACL Remove

http://acsgw/acl/remove/
{
	"prefix":	"192.0.2.0/24",
}

##### ACL List

To retrieve the configured ACL ACSdb can call:

GET http://acsgw/acl/list/
{
	"prefixes":
	[
		{
			"prefix": "10.0.0.0/8",
			"verdict": "block",
		},
		{
			"prefix": "192.0.2.0/24",
			"verdict": "ignore",
		}
	]
}

### Address Change Signaling (ACS)

#### Initial Query

The Initial Query is a simple "GET http://192.0.2.1/" performed by the ACScl.

ACSgw replies with a standard static page and a Set-Cookie using the
cookiename from the Listener Add Initial and a random throw-away value.
The Cookie indicates what Cookie-name to use for the Redirect phase.

#### Wait

The ACScl waits for wait + random(window) seconds.

#### Redirect Query

ACScl performs a "GET http://192.0.2.2/" passing the Cookie-name from
Initial (partially proving it hit Initial before, otherwise it would not
know the correct Cookie-name). The value of the cookie is a
base64(sha256(initial-address + NET-passphrase + wait + window)) thus
proving that it really knows the initial and that the passphrase is known
to the client too. The timing then also proves it has the window/wait as
when that IP hits any IP too often it will be detected as a scanner.

ACSgw checks all cookies that the client sends and compares them to the
listeners added using the APRP "Listener Add Redirect" request.

If the cookie matches an entry, ACSgw returns the bridges JSON object
which is a copy of the "bridges" string in APRP /listener/add/redirect/.

As the client has the NET-passphrase it can decode the message and it has
the answer and thus the list of possible bridges it can use.

#### Relay Query (direct)

In this mode, ACSgw can only check that the source address is not blocked
due to scanning.

It thus just accepts the connection, performs the block check (and drops
the connection if it does not pass) and then forwards the connection to
the indicated bridge.

#### Relay Query (http)

In this mode, ACSgw checks if the source address is blocked, if so, it
returns DECLINED to Apache which then can formulate an appropriate response.

If the source address is not blocked, we match up the correct bridge by
checking if the cookie matches any of the bridges that we have
registered based on a /listener/add/relay/ request.

If that matches, we have a bridge and forward the request to it.

#### Possible known ways to break ACS

##### Rewriting Cookie name/values

Change the Cookie in responses, eg prefix both the name and value
each with standard string. Then when the client sends a cookie just
strip this standard string again.

Clients are not supposed to do calculations on cookie details, and
thus changing them on that side is doable for an adversary.

Though having stated that, javascript could ask for the cookie-name
and that would require the adversary to fix up that javascript too
which is a heavier operation. Similarly the cookie-value could contain
options that the javascript client uses. Thus when javascript gets
involved changing becomes trickier.

The above scheme is stateless though and would thus be only a very
minor performance hit if an adversary would like to do this for
possibly only some queries that it expects to be ACS related.

##### Response rewriting (breaking the Steg)

An adversary could make minor changes in most data returned from
the server:
 - resize or 1 degree rotate of images
 - change "works" to "<span>wo</span>rks" in HTML
 - javascript:
   - "optimize" variable names
   - insert junk javascript), eg "magicvar = magicvar + 1" which keeps
the script valid.

There is thus no real way to have a 100% clean data stream if the
adversary goes this route unless we use a FEC algorithm and make the
data very redundant.

But even with FEC the adversary could just add a char every third
letter and remove those and be quite happy, visually the same, but our
steg would be broken.

Eg changing just 's' into <span>s</span> for HTML content. We could
partially 'solve' that one by asking the in browser DOM for the actual
rendered text and thus ignoring whitespace though.

