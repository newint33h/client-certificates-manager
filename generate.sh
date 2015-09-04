#!/bin/bash

cd $(dirname $0)

source ./settings.conf

if [ ! -f "$CA.crt" ];
then
    echo "ERROR - Missing CA configuration in settings.conf"
    exit 1
fi

# Usage: generate <client1-file-name:client1-description> <client2...>
function generate {
  clients=("$@")

  for client in "$*"
  do
    name=`echo "$client" | cut -d : -f 1`
    description=`echo "$client" | cut -d : -f 2`

    if grep -Fq "filename($name)" log.txt
    then
	echo "ERROR - The filename is already used by:"
	grep "filename($name)" log.txt
	exit 1
    fi

    if grep -Fq "description($description)" log.txt
    then
        echo "ERROR - The user name is already used by:"
        grep "description($description)" log.txt
        exit 1
    fi

    echo "Creating clients $name ($description)..."

    echo "Generating key..."
    openssl genrsa -out clients/$name.key $BITS > /dev/null
    echo "Generating certificate..."
    openssl req -new -key clients/$name.key -out clients/$name.csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/CN=$description/O=$ORGANIZATION/" || exit 1
    echo "Signing certificate..."
    openssl x509 -req -days $DAYS -in clients/$name.csr -CA "$CA.crt" -CAkey "$CA.key" -CAserial "$CA.srl" -out clients/$name.crt || exit 1
    echo "Generating PFX..."
    openssl pkcs12 -export -out clients/$name.pfx -inkey clients/$name.key -in clients/$name.crt -certfile "$CA.crt" -passout pass:$EXPORT_PASS || exit 1
    echo "$(date) - filename($name), description($description)" >> log.txt
    chown $PFX_USER clients/$name.pfx
    echo "Done."
  done  

}

if [ "$#" -eq 1 ]; 
then
	echo "Generating certificate..."
	generate $@
else
	echo "Usage: sudo ./generate.sh \"filename:User Name\""
	echo "  Ex. \$ sudo ./generate.sh \"pancho:Pancho Villa\""
fi
