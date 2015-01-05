#!/bin/sh

# Pre-requirements:
# - Start postgresql (+ setup perms)
# - Start acsdb (./acsdb.go)
# - Start acsgw (./acsgw.go)
#
# After that, just start this script
# All of this runs locally
#
# Provide a parameter to specify an IP address of a webserver

# Sets up an experimental setup
# Run from 'src' directory 

set -e

# Configure the Database
./acsdb.go --setup-db
./acsdb.go --user-add gw1 gw1-password
./acsdb.go --user-add admin test

# Setup the Gateway
./acsgw.go --setup-db

# Setup Address pools
./acsgw.go --pool-add 10.1.1.48/28
./acsgw.go --pool-add 10.2.2.48/28
./acsgw.go --pool-add 10.3.3.48/28
#./acsgw.go --pool-add 2001:db8:6000:1111::/120
#./acsgw.go --pool-add 2001:db8:6000:2222::/120

# Add a bridge
if [ $# -eq 0 ];
then
	./acsgw.go --bridge-add bridge1 stegotorus 127.0.0.1 8091 '{ "key": "12345", "mode": "cool" }'
	./acsgw.go --bridge-add bridge2 meek 127.0.0.1 8092 "none"
else
	./acsgw.go --bridge-add bridge1 web $1 80 "none"
fi

# Generate a ticket that can be used
./acsdb.go --ticket-create /tmp/acs.net

# Perform ACS using that ticket
./acscl.go --test-relay --force-port 8082 /tmp/acs.net

echo "================"
echo "Test Setup Ready"
echo ""
echo "More tickets:"
echo "./acsdb.go --ticket-create /tmp/acs.net"
echo "./acscl.go --test-relay --force-port 8082 /tmp/acs.net"

