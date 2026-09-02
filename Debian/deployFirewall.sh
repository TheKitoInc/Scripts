#!/usr/bin/env bash
set -e

echo "=== Installing iptables ==="

if ! command -v iptables >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y iptables
fi

if ! command -v ip6tables >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y iptables
fi

IPTABLES="$(command -v iptables)"
IP6TABLES="$(command -v ip6tables)"

echo "=== Detecting main network interface ==="

MAIN_IFACE="$(ip route show default | awk 'NR==1 {print $5}')"

if [ -z "$MAIN_IFACE" ]; then
    echo "ERROR: Could not determine main network interface" >&2
    exit 1
fi

echo "Main interface: $MAIN_IFACE"

echo "=== Configuring IPv4 firewall ==="

"$IPTABLES" -F
"$IPTABLES" -X
"$IPTABLES" -P INPUT DROP
"$IPTABLES" -P FORWARD DROP
"$IPTABLES" -P OUTPUT ACCEPT
"$IPTABLES" -A INPUT -i lo -j ACCEPT
"$IPTABLES" -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
"$IPTABLES" -A INPUT -i "$MAIN_IFACE" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

echo "=== Configuring IPv6 firewall ==="

"$IP6TABLES" -F
"$IP6TABLES" -X
"$IP6TABLES" -P INPUT DROP
"$IP6TABLES" -P FORWARD DROP
"$IP6TABLES" -P OUTPUT ACCEPT
"$IP6TABLES" -A INPUT -i lo -j ACCEPT
"$IP6TABLES" -A INPUT -p ipv6-icmp -j ACCEPT
"$IP6TABLES" -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
"$IP6TABLES" -A INPUT -i "$MAIN_IFACE" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

echo "=== Firewall configuration complete ==="

"$IPTABLES" -L -n -v
"$IP6TABLES" -L -n -v
