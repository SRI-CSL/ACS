# Addresspools Change Signaling (ACS)

Please see [ACS](doc/acs.md) for more details about the protocol.
Various terms and definitions are defined there.

[JumpBox](http://github.com/SRI-CSL/jumpbox) has a built in ACS client and acscl.go can be used for quick tests too or automated usage.

See [TestSetup](doc/testsetup.md) for a method of testing ACS on a local host.

![SAFDEF](https://github.com/SRI-CSL/ACS/blob/master/doc/safdef.png "SAFDEF")

# Installation and Setup

## Debian

### Installation

On the database:
```
apt-get install acsdb
```

On the gateway:
```
apt-get install acsgw
```

## Mac OSX

### Installation

Install go:
```
brew install go
```

Install PostgreSQL Go driver:
```
go get github.com/lib/pq
```

Install PostgreSQL (unless one has a server on another host):
```
brew install postgresql
```

Initialize the database for each component, ACSdb:
```
acsdb --setupdb
```

and ACSgw:
```
acsgw --setupdb
```


### Starting

Start PostgreSQL (or see instructions from brew to do this automatically)
```
  postgres -D /usr/local/var/postgres &
```

Start ACSdb:
```
acsdb
```

Start ACSgw:
```
acsgw
```

Note that acsdb and acsgw use /usr/bin/env for finding the 'go' binary.
In the source directory they are named with the .go extension to clarify that
they are actually go sources. Debian package goes without that extension.

# Usage phases

## Initial Setup

- Installation of components / Debian package
- ACSdb: Init PSQL (acsdb --setup-psql)
- ACSdb: Add PSQL Schemas (acsdb --setup-db)
- ACSdb: Start

## Gateway Setup

- ACSgw: Init PSQL (acsgw --setup-psql)
- ACSgw: Add PSQL Schemas (acsgw --setup-db)
- ACSdb: Add ACSgw details (user/pass) to ACSdb (acsdb --gateway-add <username> <password>)
- ACSgw: Start up with ACSdb hostname(s)
- ACSgw: Start Ping ACSdb (db:/gw/ping/)
- ACSgw: Add Address Pool (db:/pool/add/)
- ACSgw: Add Bridge (db:/bridge/add/)

## Request NETs

When a Pool + Bridge are registered:

- ACSdb: Admin requests a ticket (acsdb --ticket-create)
  - ACSdb: selects listeners and parameters
  - ACSdb informs ACSgw of the new listeners (gw:/listeners/add/${state}/)

## User performs ACS

- ACScl: ACS Initial
  - ACSgw: check initial + return answer
- ACScl: ACS Redirect
  - ACSgw: check redirect + return answer
- ACScl: ACS Bridge
  - ACSgw: Forward traffic

# Misc
- ACSgw: each connection causes a Hit to be registerd (db:/gw/hit)

## Generate a SSL certificate

For generating self-signed certificates for use with ACSdb and ACSgw one can use
the standard generate_cert script included in the crypto package in Go:

```
go run /usr/local/Cellar/go/1.2.1/libexec/src/pkg/crypto/tls/generate_cert.go --rsa-bits 512 --host 127.0.0.1,::1,localhost --ca --start-date "Jan 1 00:00:00 1970" --duration=1000000h
```

Add/Change the hosts/IP addresses in the --host option for adding names.

"Official" certificates can be used too of course. Though likely at that point
it is better to have Apache or NGINX handle the TLS and just proxy to the server
in question.

## go Documentation

For use while traveling / not having google available:

```
go get code.google.com/p/go.tools/cmd/godoc
export PATH=$PATH:/usr/local/opt/go/libexec/bin
godoc -http :6060
```

and voila full go documentation on http://localhost:6060

## Todo/notes list

- ACL support
- Blocking of hosts that scan (wait/window protection)
- Steg support (JEL)
- Standardize direct, http-stegotorus, http-meek etc
- Add CASCADE DELETES for when we remove an item
- Hostname support in NET
- Note that a ACSgw has to be online/responsive to be used, otherwise it gets marked down
  and not used. ACSgw thus has to check in with ACSdb at start-up to activate itself.
  It will then be considered online again till it fails to process a request
- /{pool|bridge|listener}/list/ for verifying things manually
  or maybe under /status/, have to decide
- Use HTTPS
  - Certs have to verify, can use own CA
  - Due to VPN/firewall we do not mind details in the cert
    eg, showing the hostname of the node/service
- Move to Digest Auth, though it should not be needed when using HTTPS
- Firewall off the control HTTP ports:
  - ACSgw can talk to ACSdb and vice versa, nothing else
  - Send ICMP Port Unreachable for rejections
  - alternatively we run behind nginx with custom domain
  - alternatively control infra is on a VPN'd network

