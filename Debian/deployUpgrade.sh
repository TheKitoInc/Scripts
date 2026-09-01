#!/usr/bin/env bash

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# ROOT CHECK
# ------------------------------------------------------------------------------

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: Please run this script as root."
    exit 1
fi

# ------------------------------------------------------------------------------
# APT CONFIGURATION
# ------------------------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

echo "=== Configuring APT repositories ==="

cat > /etc/apt/sources.list <<'EOF'
deb http://deb.debian.org/debian stable main
deb-src http://deb.debian.org/debian stable main

deb http://deb.debian.org/debian stable-updates main
deb-src http://deb.debian.org/debian stable-updates main

deb http://security.debian.org/debian-security stable-security main
deb-src http://security.debian.org/debian-security stable-security main
EOF

if [[ -d /etc/apt/sources.list.d ]]; then
    find /etc/apt/sources.list.d -type f -name '*.sources' -delete
    find /etc/apt/sources.list.d -type f -name '*.list' -delete
fi

# ------------------------------------------------------------------------------
# UPDATE
# ------------------------------------------------------------------------------

echo "=== Updating package lists ==="

apt-get update

# ------------------------------------------------------------------------------
# UPGRADE
# ------------------------------------------------------------------------------

echo "=== Performing upgrade ==="

apt-get upgrade -y

echo "=== Performing distribution upgrade ==="

apt-get dist-upgrade -y


# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------

echo "=== Removing unused packages ==="

apt-get autoremove -y

echo "=== Cleaning package cache ==="

apt-get autoclean -y

echo
echo "=== System upgrade completed ==="
echo

# ------------------------------------------------------------------------------
# REBOOT CHECK
# ------------------------------------------------------------------------------

if [[ -f /var/run/reboot-required ]]; then
    echo "WARNING: Reboot is required."
    echo "WARNING: Reboot was not performed automatically."
else
    echo "=== No reboot required ==="
fi

exit 0