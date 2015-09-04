#!/bin/bash

source ./settings.conf

if [ -f "$CA.crt" ];
then
    echo "ERROR - The CA is already created"
    exit 1
fi

openssl genrsa -out "$CA.key" $BITS
openssl req -new -x509 -days $DAYS -key "$CA.key" -out "$CA.crt" -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/CN=$CA_COMMON_NAME/O=$ORGANIZATION/"

> log.txt

echo "01" > "$CA.srl"

> crl/index.txt
echo "01" > crl/crlnumber
openssl ca -config ./openssl.conf -gencrl -keyfile "$CA.key" -cert "$CA.crt" -out $CRL_OUTPUT
