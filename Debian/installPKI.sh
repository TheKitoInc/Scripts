#/bin/bash

export DEBIAN_FRONTEND=noninteractive;

apt-get update || exit 101
apt-get install easy-rsa curl -y || exit 102

export EASYRSA_BATCH=1
EASYRSA=/usr/share/easy-rsa/easyrsa
PKI=/etc

FQDN=$(grep -m 1 . /etc/hostname)
FQDN=${FQDN,,}
DOMAIN=$(echo $FQDN| cut -d. -f2-255)
FQDN=${FQDN^^}
HOSTNAME=$(echo $FQDN | cut -d. -f1)

CNClient=$HOSTNAME
CNServer=$HOSTNAME.$DOMAIN

[ -d "$PKI/pki" ] || (cd "$PKI" && $EASYRSA init-pki) || exit 121

[ -d "$PKI/pki/reqs/" ] || (mkdir "$PKI/pki/reqs/") || exit 131
[ -d "$PKI/pki/issued/" ] || (mkdir "$PKI/pki/issued/") || exit 132
[ -d "$PKI/pki/private/" ] || (mkdir "$PKI/pki/private/") || exit 133

[ -f "$PKI/pki/dh.pem" ] || (cd "$PKI" && $EASYRSA gen-dh) || exit 141

[ -f "$PKI/pki/reqs/$CNClient.req" ] || (cd "$PKI" && $EASYRSA gen-req $CNClient nopass) || exit 151
[ -f "$PKI/pki/reqs/$CNServer.req" ] || (cd "$PKI" && $EASYRSA gen-req $CNServer nopass) || exit 152

[ -L "$PKI/pki/reqs/client.req" ] || (cd "$PKI/pki/reqs/" && ln -s $CNClient.req client.req) || exit 161
[ -L "$PKI/pki/reqs/server.req" ] || (cd "$PKI/pki/reqs/" && ln -s $CNServer.req server.req) || exit 162

[ -L "$PKI/pki/private/client.key" ] || (cd "$PKI/pki/private/" && ln -s $CNClient.key client.key) || exit 171
[ -L "$PKI/pki/private/server.key" ] || (cd "$PKI/pki/private/" && ln -s $CNServer.key server.key) || exit 172

[ -L "$PKI/pki/issued/client.crt" ] || (cd "$PKI/pki/issued/" && ln -s $CNClient.crt client.crt) || exit 181
[ -L "$PKI/pki/issued/server.crt" ] || (cd "$PKI/pki/issued/" && ln -s $CNServer.crt server.crt) || exit 182

cat "$PKI/pki/reqs/$CNClient.req" | curl -X POST --data-binary @- https://pki.$DOMAIN/csr/$CNClient.csr
cat "$PKI/pki/reqs/$CNServer.req" | curl -X POST --data-binary @- https://pki.$DOMAIN/csr/$CNServer.csr

curl -X GET "https://pki.$DOMAIN/crt/$CNClient.crt" > /tmp/$CNClient.crt && mv "/tmp/$CNClient.crt" "$PKI/pki/issued/"
curl -X GET "https://pki.$DOMAIN/crt/$CNServer.crt" > /tmp/$CNServer.crt && mv "/tmp/$CNServer.crt" "$PKI/pki/issued/"
