#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Checking privileges ==="

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must run as root." >&2
    exit 1
fi

echo "=== Detecting network configuration ==="

NIC="$(ip route show default | awk 'NR==1 {print $5}')"

if [ -z "$NIC" ]; then
    echo "ERROR: Could not detect network interface." >&2
    exit 1
fi

IPv4="$(ip -4 addr show dev "$NIC" | awk '/inet / && $2 !~ /^127\./ {print $2; exit}')"
IPv4_ADDR="${IPv4%/*}"

IPv4GW="$(ip -4 route show default | awk 'NR==1 {print $3}')"

IPv6="$(ip -6 addr show dev "$NIC" | awk '/inet6 / && $2 !~ /^fe80:/ {print $2; exit}')"
IPv6_ADDR="${IPv6%/*}"

IPv6GW="$(ip -6 route show default | awk 'NR==1 {print $3}')"

echo "Interface : $NIC"
echo "IPv4      : $IPv4_ADDR"
echo "IPv4 GW   : $IPv4GW"
echo "IPv6      : $IPv6_ADDR"
echo "IPv6 GW   : $IPv6GW"

if [ -z "$IPv4_ADDR" ] || [ -z "$IPv4GW" ]; then
    echo "ERROR: Could not detect IPv4 configuration." >&2
    exit 1
fi

echo "=== Stopping network managers ==="

if systemctl is-active --quiet systemd-networkd; then
    systemctl stop systemd-networkd
fi

if systemctl is-active --quiet NetworkManager; then
    systemctl stop NetworkManager
fi

if systemctl is-active --quiet dhcpcd; then
    systemctl stop dhcpcd
fi

if pgrep -x dhclient >/dev/null 2>&1; then
    pkill -x dhclient || true
fi

echo "=== Applying IPv4 configuration ==="

ip -4 addr replace "$IPv4_ADDR/32" dev "$NIC"
ip -4 route replace "$IPv4GW" dev "$NIC"
ip -4 route replace default via "$IPv4GW" dev "$NIC"

if [ -n "$IPv6_ADDR" ] && [ -n "$IPv6GW" ]; then
    echo "=== Applying IPv6 configuration ==="

    ip -6 addr replace "$IPv6_ADDR/128" dev "$NIC"
    ip -6 route replace "$IPv6GW" dev "$NIC"
    ip -6 route replace default via "$IPv6GW" dev "$NIC"
fi

echo "=== Network configuration ==="

ip -4 addr show dev "$NIC"
ip -4 route

if [ -n "$IPv6_ADDR" ]; then
    ip -6 addr show dev "$NIC"
    ip -6 route
fi

echo
echo "=== Runtime network configuration complete ==="
