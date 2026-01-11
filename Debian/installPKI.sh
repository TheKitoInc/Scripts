#!/bin/bash
set -Eeuo pipefail

trap 'echo "❌ Error on line $LINENO: $BASH_COMMAND" >&2' ERR

export DEBIAN_FRONTEND=noninteractive
export EASYRSA_BATCH=1

apt-get update
apt-get install -y easy-rsa curl

EASYRSA="/usr/share/easy-rsa/easyrsa"
PKI="/etc"

# Get hostname / domain
FQDN=$(head -n1 /etc/hostname)
FQDN=${FQDN,,}
DOMAIN=$(echo "$FQDN" | cut -d. -f2-255)
FQDN=${FQDN^^}
HOSTNAME=$(echo "$FQDN" | cut -d. -f1)

CNClient="$HOSTNAME"
CNServer="$HOSTNAME.$DOMAIN"

# Init PKI if needed
if [ ! -d "$PKI/pki" ]; then
    (cd "$PKI" && "$EASYRSA" init-pki)
fi

# Ensure directories exist
mkdir -p \
    "$PKI/pki/reqs" \
    "$PKI/pki/issued" \
    "$PKI/pki/private"

# Generate DH params if missing
if [ ! -f "$PKI/pki/dh.pem" ]; then
    (cd "$PKI" && "$EASYRSA" gen-dh)
fi

# Generate cert requests if missing
if [ ! -f "$PKI/pki/reqs/$CNClient.req" ]; then
    (cd "$PKI" && "$EASYRSA" gen-req "$CNClient" nopass)
fi

if [ ! -f "$PKI/pki/reqs/$CNServer.req" ]; then
    (cd "$PKI" && "$EASYRSA" gen-req "$CNServer" nopass)
fi

# Symlinks
ln -sf "$CNClient.req" "$PKI/pki/reqs/client.req"
ln -sf "$CNServer.req" "$PKI/pki/reqs/server.req"

ln -sf "$CNClient.key" "$PKI/pki/private/client.key"
ln -sf "$CNServer.key" "$PKI/pki/private/server.key"

ln -sf "$CNClient.crt" "$PKI/pki/issued/client.crt"
ln -sf "$CNServer.crt" "$PKI/pki/issued/server.crt"

# Upload CSRs
curl -f -X POST --data-binary @"$PKI/pki/reqs/$CNClient.req" \
    "https://pki.$DOMAIN/csr/$CNClient.csr"

curl -f -X POST --data-binary @"$PKI/pki/reqs/$CNServer.req" \
    "https://pki.$DOMAIN/csr/$CNServer.csr"

# Download certificates safely
curl -f -o "/tmp/$CNClient.crt" "https://pki.$DOMAIN/crt/$CNClient.crt"
mv "/tmp/$CNClient.crt" "$PKI/pki/issued/"

curl -f -o "/tmp/$CNServer.crt" "https://pki.$DOMAIN/crt/$CNServer.crt"
mv "/tmp/$CNServer.crt" "$PKI/pki/issued/"

echo "✅ PKI setup completed successfully"
