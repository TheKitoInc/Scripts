#!/bin/bash
WGET=$(which "wget")
IPSET=$(which "ipset")
IPTABLES=$(which "iptables")
IP6TABLES=$(which "ip6tables")

$IPSET -exist -N cloudFlareV4 hash:net
$WGET --inet4-only -q https://www.cloudflare.com/ips-v4 -O - | while read ip
do
        $IPSET -exist -A cloudFlareV4 $ip
done
$IPTABLES -A INPUT  -p tcp --dport 80  -m set --match-set cloudFlareV4 src -j ACCEPT
$IPTABLES -A INPUT  -p tcp --dport 443 -m set --match-set cloudFlareV4 src -j ACCEPT

$IPSET -exist -N cloudFlareV6 hash:net family inet6
$WGET --inet6-only -q https://www.cloudflare.com/ips-v6 -O - | while read ip
do
        $IPSET -exist -A cloudFlareV6 $ip
done
$IP6TABLES -A INPUT -p tcp --dport 80  -m set --match-set cloudFlareV6 src -j ACCEPT
$IP6TABLES -A INPUT -p tcp --dport 443 -m set --match-set cloudFlareV6 src -j ACCEPT
