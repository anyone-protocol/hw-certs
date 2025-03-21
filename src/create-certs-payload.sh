#!/bin/bash

# Unzip certs
unzip -o certs.zip
chmod 644 certs

# Create json payload
echo -n "{\"certificate\":\"" > certs.json
for i in certs/*.cer; do
  openssl x509 -in $i -inform DER -outform PEM >> certs.json;
  echo "Converted $i to PEM and added to payload";
done
echo -n "\"}" >> certs.json

# Escape newlines
awk 1 ORS='\\n' certs.json > certs.json.tmp
# Remove last two chars (escaped \n)
sed 's/..$//' < certs.json.tmp > certs.json
rm certs.json.tmp
echo "Payload created: certs.json"
