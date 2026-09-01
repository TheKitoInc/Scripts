#!/usr/bin/env bash
set -e

echo "=== Installing required packages ==="

if ! command -v wget >/dev/null 2>&1; then
    apt-get update
    apt-get install -y wget
fi

if ! command -v ipset >/dev/null 2>&1; then
    apt-get update
    apt-get install -y ipset
fi

if ! command -v iptables >/dev/null 2>&1; then
    apt-get update
    apt-get install -y iptables
fi

if ! command -v ip6tables >/dev/null 2>&1; then
    apt-get update
    apt-get install -y iptables
fi

WGET="$(command -v wget)"
IPSET="$(command -v ipset)"
IPTABLES="$(command -v iptables)"
IP6TABLES="$(command -v ip6tables)"

echo "=== Configuring Cloudflare IPv4 ==="

"$IPSET" -exist -N cloudFlareV4 hash:net

"$WGET" --inet4-only -q https://www.cloudflare.com/ips-v4 -O - |
while read -r ip; do
    "$IPSET" -exist -A cloudFlareV4 "$ip"
done

"$IPTABLES" -S | grep -w "80" | grep -w "cloudFlareV4" >/dev/null ||
    "$IPTABLES" -A INPUT -p tcp --dport 80 \
        -m set --match-set cloudFlareV4 src -j ACCEPT

"$IPTABLES" -S | grep -w "443" | grep -w "cloudFlareV4" >/dev/null ||
    "$IPTABLES" -A INPUT -p tcp --dport 443 \
        -m set --match-set cloudFlareV4 src -j ACCEPT

echo "=== Configuring Cloudflare IPv6 ==="

"$IPSET" -exist -N cloudFlareV6 hash:net family inet6

"$WGET" --inet6-only -q https://www.cloudflare.com/ips-v6 -O - |
while read -r ip; do
    "$IPSET" -exist -A cloudFlareV6 "$ip"
done

"$IP6TABLES" -S | grep -w "80" | grep -w "cloudFlareV6" >/dev/null ||
    "$IP6TABLES" -A INPUT -p tcp --dport 80 \
        -m set --match-set cloudFlareV6 src -j ACCEPT

"$IP6TABLES" -S | grep -w "443" | grep -w "cloudFlareV6" >/dev/null ||
    "$IP6TABLES" -A INPUT -p tcp --dport 443 \
        -m set --match-set cloudFlareV6 src -j ACCEPT

echo "=== Cloudflare firewall configuration complete ==="