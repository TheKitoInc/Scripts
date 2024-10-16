#/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters: nodeID"
    exit 1
fi

(cat /etc/sysctl.conf | grep "net.ipv4.ip_forward = 1") || (echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p /etc/sysctl.conf) || exit 20

PORTIP6=1194
PORTIP4=1195

NODEID=$1
NODENET=10.128.$(( 4*$NODEID )).0
NODEMSK=255.255.252.0

NODENETA=10.128.$(( 4*$NODEID + 0))
NODENETB=10.128.$(( 4*$NODEID + 1))
NODENETC=10.128.$(( 4*$NODEID + 2))
NODENETD=10.128.$(( 4*$NODEID + 3))

export DEBIAN_FRONTEND=noninteractive;

apt-get update || exit 1
apt-get install openvpn openvpn-dco-dkms -y || exit 2

[ ! -d "/etc/openvpn/server" ] || (rmdir "/etc/openvpn/server") || exit 16
[ ! -d "/etc/openvpn/client" ] || (rmdir "/etc/openvpn/client") || exit 17
[ ! -f "/etc/openvpn/update-resolv-conf" ] || (rm "/etc/openvpn/update-resolv-conf") || exit 18
[ -d "/etc/openvpn/ccd" ] || (mkdir "/etc/openvpn/ccd") || exit 19

CONFIGBASE=$(echo "
topology subnet

ca      /etc/pki/issued/ca.crt
cert    /etc/pki/issued/server.crt
key     /etc/pki/private/server.key
dh      /etc/pki/dh.pem

keepalive 5 10
persist-key
persist-tun
verb 3

client-config-dir /etc/openvpn/ccd
ccd-exclusive
")

echo "$CONFIGBASE

port $PORTIP4
proto tcp-server
dev tunTCPv4

status /var/log/openvpn-statusTCPv4.log

server $NODENETA.0 255.255.255.0
push \"route $NODENET $NODEMSK $NODENETA.1 4\"
push \"route 10.128.0.0 255.255.0.0 $NODENETA.1 14\"

push \"route 192.168.0.0 255.255.0.0 $NODENETA.1 24\"
push \"route 172.16.0.0 255.240.0.0 $NODENETA.1 24\"
push \"route 10.0.0.0 255.0.0.0 $NODENETA.1 24\"
" > /etc/openvpn/serverTCPv4.conf || exit 21

echo "$CONFIGBASE

port $PORTIP4
proto udp
dev tunUDPv4

status /var/log/openvpn-statusUDPv4.log

server $NODENETB.0 255.255.255.0
push \"route $NODENET $NODEMSK $NODENETB.1 3\"
push \"route 10.128.0.0 255.255.0.0 $NODENETB.1 13\"

push \"route 192.168.0.0 255.255.0.0 $NODENETB.1 23\"
push \"route 172.16.0.0 255.240.0.0 $NODENETB.1 23\"
push \"route 10.0.0.0 255.0.0.0 $NODENETB.1 23\"
" > /etc/openvpn/serverUDPv4.conf || exit 22

echo "$CONFIGBASE

port $PORTIP6
proto tcp6-server
dev tunTCPv6

status /var/log/openvpn-statusTCPv6.log

server $NODENETC.0 255.255.255.0
push \"route $NODENET $NODEMSK $NODENETC.1 2\"
push \"route 10.128.0.0 255.255.0.0 $NODENETC.1 12\"

push \"route 192.168.0.0 255.255.0.0 $NODENETC.1 22\"
push \"route 172.16.0.0 255.240.0.0 $NODENETC.1 22\"
push \"route 10.0.0.0 255.0.0.0 $NODENETC.1 22\"
" > /etc/openvpn/serverTCPv6.conf || exit 23

echo "$CONFIGBASE

port $PORTIP6
proto udp6
dev tunUDPv6

status /var/log/openvpn-statusUDPv6.log

server $NODENETD.0 255.255.255.0
push \"route $NODENET $NODEMSK $NODENETD.1 1\"
push \"route 10.128.0.0 255.255.0.0 $NODENETD.1 11\"

push \"route 192.168.0.0 255.255.0.0 $NODENETD.1 21\"
push \"route 172.16.0.0 255.240.0.0 $NODENETD.1 21\"
push \"route 10.0.0.0 255.0.0.0 $NODENETD.1 21\"
" > /etc/openvpn/serverUDPv6.conf || exit 24

