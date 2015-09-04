#!/bin/bash

cd $(dirname $0)

source ./settings.conf

if [ ! -f "$CA.crt" ];
then
    echo "ERROR - Missing CA configuration in settings.conf"
    exit 1
fi

if [ $# -eq 0 ];
then
	echo "Usage: sudo ./revoke.sh \"User Name or filename\""
	echo "  Ex. $ sudo ./revoke.sh test"
	echo "  Ex. $ sudo ./revoke.sh \"Test User\""
	exit 1
fi

function revoke {
	echo "Revoking certificate $1.crt ..."
	openssl ca -config ./openssl.conf -revoke clients/$1.crt -keyfile "$CA.key" -cert "$CA.crt"
	if [ "$?" -ne 0 ];
	then
		exit 1
	fi
        openssl ca -config ./openssl.conf -gencrl -keyfile "$CA.key" -cert "$CA.crt" -out $CRL_OUTPUT
	echo "Done."
	echo "CRL file updated: $CRL_OUTPUT"
}

if [ -f clients/$1.crt ];
then
	revoke $1
	exit 0
fi

entry=$(grep "description($1)" ../log.txt)
if [ ! -z "$entry" ];
then
        filename=$(echo $entry | grep -oP "filename\((.*)\)," | cut -d "(" -f 2 | cut -d ")" -f 1)
	revoke $filename
	exit 0
fi

echo "ERROR - The user name or file name was not found."
exit 1
