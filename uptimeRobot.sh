#!/bin/bash
WGET=$(which "wget")
IPSET=$(which "ipset")
IPTABLES=$(which "iptables")
IP6TABLES=$(which "ip6tables")

$IPSET -exist -N uptimeRobotV4 hash:net
$WGET --inet4-only -q https://uptimerobot.com/inc/files/ips/IPv4.txt -O - | tr -d '\r' | while read ip
do
        $IPSET -exist -A uptimeRobotV4 $ip
done
$IPTABLES -A INPUT  -p tcp --dport 80  -m set --match-set uptimeRobotV4 src -j ACCEPT
$IPTABLES -A INPUT  -p tcp --dport 443 -m set --match-set uptimeRobotV4 src -j ACCEPT

$IPSET -exist -N uptimeRobotV6 hash:net family inet6
$WGET --inet6-only -q https://uptimerobot.com/inc/files/ips/IPv6.txt -O - | tr -d '\r' | while read ip
do
        $IPSET -exist -A uptimeRobotV6 $ip
done
$IP6TABLES -A INPUT -p tcp --dport 80  -m set --match-set uptimeRobotV6 src -j ACCEPT
$IP6TABLES -A INPUT -p tcp --dport 443 -m set --match-set uptimeRobotV6 src -j ACCEPT
