#!/usr/bin/env bash
set -euo pipefail

echo "=== Updating hostname from PTR ==="

IP="$(hostname -I | awk '{print $1}')"

PTR="$(dig +short -x "$IP" | head -n1 | sed 's/\.$//')"

if [ -z "$PTR" ]; then
    echo "ERROR: No PTR record found for $IP" >&2
    exit 1
fi

HOST="${PTR%%.*}"
DOMAIN="${PTR#*.}"

HOST="$(printf '%s' "$HOST" | tr '[:lower:]' '[:upper:]')"
DOMAIN="$(printf '%s' "$DOMAIN" | tr '[:upper:]' '[:lower:]')"

FQDN="${HOST}.${DOMAIN}"

echo "IP:       $IP"
echo "PTR:      $PTR"
echo "Hostname: $HOST"
echo "FQDN:     $FQDN"

hostnamectl set-hostname "$FQDN"

echo "Hostname updated to: $FQDN"