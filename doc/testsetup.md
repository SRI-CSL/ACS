# TestSetup.sh

testsetup.sh can be used to quickly test all functionality in the Addresspools suite, thus ACS and APRP.

Use either the [OSX](osx_addr_setup.sh) or [Linux](linux_addr_setup.sh) scripts to set up the addresses needed for this test.

## Example output

Example output of testsetup.sh

This is run from the 'src' directory, 66.160.192.98 is the current address of www.safdef.org causing the relay connection
to be sent to that website (and thus returning the HTML page) instead of forwarding towards eg StegoTorus or Meek.

```
$ ../doc/testsetup.sh 66.160.192.98
acsdb: 2014/12/22 17:41:33 Setup DB - done
acsdb: 2014/12/22 17:41:34 Added gw1
acsdb: 2014/12/22 17:41:35 Added admin
acsgw: 2014/12/22 17:41:35 Setup DB - done
acsgw: 2014/12/22 17:41:36 http://localhost:8080/pool/add/
acsgw: 2014/12/22 17:41:36 8<---------------
{
	"status": "ok",
	"message": "Added 10.1.1.0/24"
}
---------------->8
acsgw: 2014/12/22 17:41:36 Added Pool 10.1.1.0/24
acsgw: 2014/12/22 17:41:37 http://localhost:8080/bridge/add/
acsgw: 2014/12/22 17:41:37 8<---------------
{
	"status": "ok",
	"message": "Bridge web added"
}
---------------->8
acsgw: 2014/12/22 17:41:37 Added Bridge bridge1
acsdb: 2014/12/22 17:41:38 /listener/add/initial/
acsdb: 2014/12/22 17:41:38 8<---------------
{
	"status": "ok",
	"message": "Added Initial Listener"
}
---------------->8
acsdb: 2014/12/22 17:41:38 /listener/add/relay/
acsdb: 2014/12/22 17:41:38 8<---------------
{
	"status": "ok",
	"message": "Added Relay Listener"
}
---------------->8
acsdb: 2014/12/22 17:41:38 /listener/add/redirect/
acsdb: 2014/12/22 17:41:38 8<---------------
{
	"status": "ok",
	"message": "Added Redirect Listener"
}
---------------->8
acscl: 2014/12/22 17:41:38 Performing Initial
acscl: 2014/12/22 17:41:38 Contacting http://10.1.1.135:8082
acscl: 2014/12/22 17:41:42 8<---------------
Welcome to this website
---------------->8
acscl: 2014/12/22 17:41:42 HTTP Cookie: sid, Value: uteyCsuES6OqZgt2CvZfWVBNPKJqZHaM1--eQP3hoN8=
acscl: 2014/12/22 17:41:42 Sleeping for the NET Wait (wait: 10, window: 10, rand-window: 7) = 17
acscl: 2014/12/22 17:41:59 Performing Redirect
acscl: 2014/12/22 17:41:59 Contacting http://10.1.1.242:8082
acscl: 2014/12/22 17:42:00 8<---------------
WwoJewoJCSJhZGRyZXNzIjogIjEwLjEuMS44MiIsCgkJInBvcnQiOiA4MCwKCQkiY29va2llIjogIlNFU1NJT049NTk1MGQ4M2JiOTA2MTIwZjMwMmEyYmVjZmQ0ZjcwMWIiLAoJCSJ0eXBlIjogIndlYiIsCgkJIm9wdGlvbnMiOiAibm9uZSAiCgl9Cl0=
---------------->8
acscl: 2014/12/22 17:42:00 Please Relay through:
8<-------------------------
[
	{
		"address": "10.1.1.82",
		"port": 80,
		"cookie": "SESSION=5950d83bb906120f302a2becfd4f701b",
		"type": "web",
		"options": "none "
	}
]
-------------------------->8

acscl: 2014/12/22 17:42:00 Testing relay queries
acscl: 2014/12/22 17:42:00 Host: 10.1.1.82, port 80
acscl: 2014/12/22 17:42:00 Forcing port to 8082
acscl: 2014/12/22 17:42:00 Contacting http://10.1.1.82:8082
acscl: 2014/12/22 17:42:03 8<---------------
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>SAFDEF - SAFER DEFIANCE by Farsight Security</title>
</head>
...
---------------->8
acscl: 2014/12/22 17:42:03 All done
================
Test Setup Ready

More tickets:
./acsdb.go --ticket-create /tmp/acs.net
./acscl.go --test-relay --force-port 8082 /tmp/acs.net
```

