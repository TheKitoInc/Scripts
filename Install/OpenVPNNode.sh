#/bin/bash

export DEBIAN_FRONTEND=noninteractive;

EASYRSA=/usr/share/easy-rsa/easyrsa
PKI=/etc/openvpn

apt-get update || exit 1
apt-get install openvpn -y || exit 2
apt-get install easy-rsa -y || exit 3

[ -d "$PKI/pki" ] || (cd "$PKI" && $EASYRSA init-pki) || exit 4
[ -f "$PKI/pki/dh.pem" ] || (cd "$PKI" && $EASYRSA gen-dh) || exit 5 
 
