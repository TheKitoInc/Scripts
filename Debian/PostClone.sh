#!/bin/bash

set -e

echo "=== Debian Clone Fix Script ==="

# 1. Regenerate machine-id
echo "[*] Resetting machine-id..."
rm -f /etc/machine-id
systemd-machine-id-setup

# Ensure dbus uses the same ID
echo "[*] Fixing D-Bus machine-id..."
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# 2. Regenerate SSH host keys
echo "[*] Regenerating SSH host keys..."
rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure -f noninteractive openssh-server

# 3. Reset network persistent rules (if present)
echo "[*] Cleaning udev persistent net rules..."
rm -f /etc/udev/rules.d/70-persistent-net.rules || true

# 4. Optionally set hostname
if [ ! -z "$1" ]; then
    NEW_HOSTNAME="$1"
    echo "[*] Setting hostname to $NEW_HOSTNAME..."
    hostnamectl set-hostname "$NEW_HOSTNAME"

    # Update /etc/hosts safely
    sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts || \
    echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
else
    echo "[!] No hostname provided. Skipping..."
fi

# 5. Clean logs (optional but useful for templates)
echo "[*] Cleaning logs..."
find /var/log -type f -exec truncate -s 0 {} \;

# 6. Clean temp directories
echo "[*] Cleaning temp directories..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# 7. Show new machine-id
echo "[*] New machine-id:"
cat /etc/machine-id

echo "=== Done. Reboot recommended ==="
