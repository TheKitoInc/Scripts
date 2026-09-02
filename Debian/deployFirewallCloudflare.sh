#!/usr/bin/env bash
set -e

echo "=== Installing required packages ==="

if ! command -v wget >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y wget
fi

if ! command -v ipset >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y ipset
fi

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

WGET="$(command -v wget)"
IPSET="$(command -v ipset)"
IPTABLES="$(command -v iptables)"
IP6TABLES="$(command -v ip6tables)"

echo "=== Configuring Cloudflare IPv4 ==="

"$IPSET" -exist -N cloudFlareV4 hash:net

"$WGET" --inet4-only -q https://www.cloudflare.com/ips-v4 -O - | while read -r ip; do
    "$IPSET" -exist -A cloudFlareV4 "$ip"
done

if ! "$IPTABLES" -S | grep -w "80" | grep -w "cloudFlareV4" >/dev/null; then
    "$IPTABLES" -A INPUT -p tcp --dport 80 -m set --match-set cloudFlareV4 src -j ACCEPT
fi

if ! "$IPTABLES" -S | grep -w "443" | grep -w "cloudFlareV4" >/dev/null; then
    "$IPTABLES" -A INPUT -p tcp --dport 443 -m set --match-set cloudFlareV4 src -j ACCEPT
fi

echo "=== Configuring Cloudflare IPv6 ==="

"$IPSET" -exist -N cloudFlareV6 hash:net family inet6

"$WGET" --inet6-only -q https://www.cloudflare.com/ips-v6 -O - | while read -r ip; do
    "$IPSET" -exist -A cloudFlareV6 "$ip"
done

if ! "$IP6TABLES" -S | grep -w "80" | grep -w "cloudFlareV6" >/dev/null; then
    "$IP6TABLES" -A INPUT -p tcp --dport 80 -m set --match-set cloudFlareV6 src -j ACCEPT
fi

if ! "$IP6TABLES" -S | grep -w "443" | grep -w "cloudFlareV6" >/dev/null; then
    "$IP6TABLES" -A INPUT -p tcp --dport 443 -m set --match-set cloudFlareV6 src -j ACCEPT
fi

echo "=== Cloudflare firewall configuration complete ==="

echo "=== IPv4 iptables rules ==="
"$IPTABLES" -L -n -v

echo "=== IPv6 iptables rules ==="
"$IP6TABLES" -L -n -v

echo "=== Cloudflare IPv4 ipset ==="
"$IPSET" list cloudFlareV4

echo "=== Cloudflare IPv6 ipset ==="
"$IPSET" list cloudFlareV6
