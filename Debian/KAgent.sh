#!/bin/bash

# =========================
# STRICT MODE (fail fast)
# =========================
set -euo pipefail

# =========================
# REQUIRE ROOT
# =========================
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi

# =========================
# CONFIG
# =========================
WORKER_URL="$1"

if [ -z "$WORKER_URL" ]; then
  echo "Usage: $0 <worker_url>"
  exit 1
fi

# =========================
# MACHINE ID (ensure exists)
# =========================
if [ ! -s /etc/machine-id ]; then
  # Try systemd way first
  if command -v systemd-machine-id-setup >/dev/null 2>&1; then
    systemd-machine-id-setup
  else
    # fallback (less ideal but works)
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id
  fi
fi

# =========================
# BASICS
# =========================
HOST=$(hostname)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# =========================
# MACHINE ID (SECRET)
# =========================
if [ -f /etc/machine-id ]; then
  MACHINE_ID=$(cat /etc/machine-id)
else
  MACHINE_ID="unknown"
fi

# Public identifier (safe to send)
MACHINE_HASH=$(printf "%s" "$MACHINE_ID" | sha1sum | awk '{print $1}')

# =========================
# HARDWARE IDS
# =========================
PRODUCT_UUID=""
BOARD_SERIAL=""

[ -r /sys/class/dmi/id/product_uuid ] && PRODUCT_UUID=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null)
[ -r /sys/class/dmi/id/board_serial ] && BOARD_SERIAL=$(cat /sys/class/dmi/id/board_serial 2>/dev/null)

# =========================
# CPU
# =========================
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
CPU_USAGE=$((100 - CPU_IDLE))

# =========================
# MEMORY
# =========================
read MEM_TOTAL MEM_USED <<< $(free -b | awk '/Mem:/ {print $2, $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

# =========================
# SWAP
# =========================
read SWAP_TOTAL SWAP_USED <<< $(free -b | awk '/Swap:/ {print $2, $3}')
if [ "$SWAP_TOTAL" -gt 0 ]; then
  SWAP_PERCENT=$((SWAP_USED * 100 / SWAP_TOTAL))
else
  SWAP_PERCENT=0
fi

# =========================
# LOAD + UPTIME
# =========================
LOAD=$(cut -d ' ' -f1 /proc/loadavg)
UPTIME=$(cut -d. -f1 /proc/uptime)

# =========================
# DISKS
# =========================
DISKS=$(df -P -T -B1 | awk '
NR>1 {
  gsub("%","",$6);
  printf "{ \"fs\": \"%s\", \"type\": \"%s\", \"size\": %s, \"used\": %s, \"avail\": %s, \"usage\": %s, \"mount\": \"%s\" },",
  $1, $2, $3, $4, $5, $6, $7
}' | sed 's/,$//')

DISK_JSON="[ $DISKS ]"

# =========================
# NETWORK
# =========================
NET=$(awk '
NR>2 {
  gsub(":","",$1);
  iface=$1;
  rx=$2;
  tx=$10;
  printf "%s %s %s\n", iface, rx, tx
}' /proc/net/dev | while read iface rx tx; do

  MAC=$(ip link show "$iface" 2>/dev/null | awk '/link\/ether/ {print $2}')

  printf "{ \"iface\": \"%s\", \"rx\": %s, \"tx\": %s, \"mac\": \"%s\" }," \
    "$iface" "$rx" "$tx" "${MAC:-""}"

done | sed 's/,$//')

NET_JSON="[ $NET ]"

# =========================
# SIGNATURE INPUT
# =========================
PRIMARY_MAC=$(ip link | awk '/link\/ether/ {print $2; exit}')
SIGN_INPUT="${TS}|${PRIMARY_MAC}|${MACHINE_HASH}"

# HMAC-SHA256 using machine-id as key
SIGNATURE=$(printf "%s" "$SIGN_INPUT" | openssl dgst -sha256 -hmac "$MACHINE_ID" | awk '{print $2}')

# =========================
# JSON
# =========================
JSON=$(cat <<EOF
{
  "host": "$HOST",
  "machine_hash": "$MACHINE_HASH",
  "timestamp": "$TS",
  "hardware": {
    "product_uuid": "$PRODUCT_UUID",
    "board_serial": "$BOARD_SERIAL"
  },
  "cpu": $CPU_USAGE,
  "load": $LOAD,
  "uptime": $UPTIME,
  "memory": {
    "total": $MEM_TOTAL,
    "used": $MEM_USED,
    "usage": $MEM_PERCENT
  },
  "swap": {
    "total": $SWAP_TOTAL,
    "used": $SWAP_USED,
    "usage": $SWAP_PERCENT
  },
  "disks": $DISK_JSON,
  "network": $NET_JSON
}
EOF
)

# =========================
# SEND
# =========================
curl -s -X POST "$WORKER_URL" \
  -H "Content-Type: application/json" \
  -H "X-Signature: $SIGNATURE" \
  -d "$JSON" \
  --max-time 10 >/dev/null 2>&1
