#/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters: nodeID"
    exit 1
fi

NODEID=$1
NODENET=10.128.$(( 4*$NODEID  ))
NODEMSK=255.255.255.252

export DEBIAN_FRONTEND=noninteractive;
export EASYRSA_BATCH=1

EASYRSA=/usr/share/easy-rsa/easyrsa
PKI=/etc/openvpn
HOST=$(hostname --fqdn)

HOST=${HOST^^}
CNClient=$(echo $HOST | cut -d. -f1)

HOST=${HOST,,}
CNServer=$CNClient.$(hostname --fqdn | cut -d. -f2-255)

apt-get update || exit 1
apt-get install openvpn -y || exit 2
apt-get install easy-rsa -y || exit 3

[ -d "$PKI/pki" ] || (cd "$PKI" && $EASYRSA init-pki) || exit 4
[ -f "$PKI/pki/dh.pem" ] || (cd "$PKI" && $EASYRSA gen-dh) || exit 5

[ -f "$PKI/pki/reqs/$CNClient.req" ] || (cd "$PKI" && $EASYRSA gen-req $CNClient nopass) || exit 6
[ -f "$PKI/pki/reqs/$CNServer.req" ] || (cd "$PKI" && $EASYRSA gen-req $CNServer nopass) || exit 7

[ -L "$PKI/pki/reqs/client.req" ] || (cd "$PKI/pki/reqs/" && ln -s $CNClient.req client.req) || exit 8
[ -L "$PKI/pki/reqs/server.req" ] || (cd "$PKI/pki/reqs/" && ln -s $CNServer.req server.req) || exit 9

[ -L "$PKI/pki/private/client.key" ] || (cd "$PKI/pki/private/" && ln -s $CNClient.key client.key) || exit 10
[ -L "$PKI/pki/private/server.key" ] || (cd "$PKI/pki/private/" && ln -s $CNServer.key server.key) || exit 11

[ -d "$PKI/pki/issued/" ] || (mkdir "$PKI/pki/issued/") || exit 12

[ -L "$PKI/pki/issued/client.crt" ] || (cd "$PKI/pki/issued/" && ln -s $CNClient.crt client.crt) || exit 13
[ -L "$PKI/pki/issued/server.crt" ] || (cd "$PKI/pki/issued/" && ln -s $CNServer.crt server.crt) || exit 14

[ ! -d "/etc/openvpn/server" ] || (rmdir "/etc/openvpn/server") || exit 15
[ ! -d "/etc/openvpn/client" ] || (rmdir "/etc/openvpn/client") || exit 16
[ ! -f "/etc/openvpn/update-resolv-conf" ] || (rm "/etc/openvpn/update-resolv-conf") || exit 17

(cat /etc/sysctl.conf | grep "net.ipv4.ip_forward = 1") || (echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p /etc/sysctl.conf)

CONFIGBASE=$(echo "
port 1194
topology subnet

ca      $PKI/pki/issued/ca.crt
cert    $PKI/pki/issued/server.crt
key     $PKI/private/server.key
dh      $PKI/pki/dh.pem

keepalive 5 10
persist-key
persist-tun
verb 3

client-config-dir /etc/openvpn/ccd
ccd-exclusive

cipher AES-256-CBC
data-ciphers AES-256-CBC
")

echo "$CONFIGBASE

proto tcp-server
dev tunTCPv4

status /var/log/openvpn-statusTCPv4.log
"

echo "$CONFIGBASE

proto udp
dev tunUDPv4

status /var/log/openvpn-statusUDPv4.log

"

echo "$CONFIGBASE

proto tcp6-server
dev tunTCPv6

status /var/log/openvpn-statusTCPv6.log


"

echo "$CONFIGBASE

proto udp6
dev tunUDPv6

status /var/log/openvpn-statusUDPv6.log

"