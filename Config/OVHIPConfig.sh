#!/bin/bash


if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters: nicName IPv4 IPv4GW IPv6 IPv6GW"
    exit 1
fi

mkdir -p /etc/network/interfaces.d/

NIC=$1
IPv4=$2
IPv4GW=$3
IPv6=$4
IPv6GW=$5


echo "
auto $NIC
allow-hotplug $NIC
iface $NIC inet static
        address $IPv4
        netmask 255.255.255.255
        post-up  /sbin/ip route add $IPv4GW dev $NIC || true
        post-up  /sbin/ip route add default via $IPv4GW dev $NIC || true
        pre-down /sbin/ip route del default via $IPv4GW dev $NIC || true
        pre-down /sbin/ip route del $IPv4GW dev $NIC || true
" > /etc/network/interfaces.d/$NIC-v4


echo "
auto $NIC
allow-hotplug $NIC
iface $NIC inet6 static
        address $IPv6/128
        post-up  /sbin/ip -6 route add $IPv6GW dev $NIC || true
        post-up  /sbin/ip -6 route add default via $IPv6GW dev $NIC || true
        pre-down /sbin/ip -6 route del default via $IPv6GW dev $NIC || true
        pre-down /sbin/ip -6 route del $IPv6GW dev $NIC || true
" > /etc/network/interfaces.d/$NIC-v6


echo "#!/bin/bash

/sbin/ip -4 addr add $IPv4/32 dev $NIC
/sbin/ip -4 route add $IPv4GW dev $NIC
/sbin/ip -4 route add default via $IPv4GW dev $NIC

/sbin/ip -6 addr  add $IPv6/128 dev $NIC
/sbin/ip -6 route add $IPv6GW   dev $NIC
/sbin/ip -6 route add default   via $IPv6GW dev $NIC

sleep 1
" > /opt/kito/scripts/net-$NIC.sh

chmod +x /opt/kito/scripts/net-$NIC.sh


echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
(test -f "/etc/network/interfaces.d/50-cloud-init") && rm "/etc/network/interfaces.d/50-cloud-init"

rm /etc/resolv.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf
