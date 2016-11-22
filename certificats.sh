#!/bin/bash

#############
# certifs
#############

current=`pwd`

cd /root
mkdir CAFREERADIUS
cd CAFREERADIUS
mkdir signed_certs
mkdir private
chmod 777 private

cp $current/openssl.cnf ./

cd /root/CAFREERADIUS

touch index.txt

echo "creation du certificat racine" ;
echo "pensez à mettre WIFI comme nom commun pour identifier la racine"
echo "TAPEZ ENTREE POUR CONTINUER ..."
read ENTREE


openssl req -new -keyout private/cakey.pem -out careq.pem -config openssl.cnf
openssl ca -create_serial -out cacert.pem -keyfile private/cakey.pem -selfsign -extensions v3_ca -config openssl.cnf -in careq.pem 
openssl x509 -inform PEM -outform DER -in cacert.pem -out cacert.der

echo "creation du certificat serveur" ;
echo "pensez à mettre serveur comme nom commun pour identifier le serveur"
echo "TAPEZ ENTREE POUR CONTINUER ..."
read ENTREE

openssl req -new -config openssl.cnf -keyout server_key.pem -out server_req.pem
openssl ca -config openssl.cnf -extensions winserver_ext -in server_req.pem -out server_cert.pem 

echo "creation du certificat client" ;
echo "pensez à mettre client comme nom commun pour identifier le client"
echo "TAPEZ ENTREE POUR CONTINUER ..."
read ENTREE

openssl req -new -config openssl.cnf -keyout windows_key.pem -out windows_req.pem
openssl ca -config openssl.cnf -extensions winclient_ext -in windows_req.pem -out windows_cert.pem

echo "transformation du certificat client au format windows PKCS12" ;
echo "TAPEZ ENTREE POUR CONTINUER ..."
read ENTREE

openssl pkcs12 -export -clcerts -in windows_cert.pem -inkey windows_key.pem -out windows.p12

cd /etc/freeradius/certs
cp /root/CAFREERADIUS/cacert.pem ./
cp /root/CAFREERADIUS/server_cert.pem ./
cp /root/CAFREERADIUS/server_key.pem ./

openssl dhparam -out dh 1024

dd if=/dev/urandom of=random count=2

echo "FIN"

