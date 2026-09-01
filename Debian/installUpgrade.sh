#!/usr/bin/env bash

################################################################################
# setup-system.sh
#
# Basic Debian VPS system configuration.
#
# - Configures Debian repositories
# - Installs common system packages
# - Creates system maintenance scripts
# - Configures automatic system upgrades
# - Runs the upgrade script once
################################################################################

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

echo "=== Updating package lists ==="

apt-get update

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------

echo "=== Installing system packages ==="

apt-get install -y \
    cron \
    supervisor \
    rsync \
    net-tools \
    htop \
    tree \
    curl \
    mutt \
    iptables \
    ipset

# ------------------------------------------------------------------------------
# DIRECTORIES
# ------------------------------------------------------------------------------

echo "=== Creating Kito directories ==="

KITO_DIR="/opt/kito"
KITO_SCRIPTS_DIR="${KITO_DIR}/scripts"

mkdir -p "${KITO_SCRIPTS_DIR}"

# ------------------------------------------------------------------------------
# SYSTEM UPGRADE SCRIPT
# ------------------------------------------------------------------------------

echo "=== Configuring system upgrade script ==="

UPGRADE_SCRIPT="${KITO_SCRIPTS_DIR}/upgradeSystem.sh"

cat > "${UPGRADE_SCRIPT}" <<'EOF'
#!/usr/bin/env bash

################################################################################
# upgradeSystem.sh
#
# Update and upgrade Debian packages.
################################################################################

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "=== Updating package lists ==="

apt-get update

echo "=== Upgrading packages ==="

apt-get upgrade -y

echo "=== Performing distribution upgrade ==="

apt-get dist-upgrade -y

echo "=== Removing unused packages ==="

apt-get autoremove -y

echo "=== Cleaning package cache ==="

apt-get autoclean -y

# ------------------------------------------------------------------------------
# REBOOT IF REQUIRED
# ------------------------------------------------------------------------------

if [[ -f /var/run/reboot-required ]]; then
    echo "=== Reboot required ==="
    reboot
fi

exit 0
EOF

chmod 755 "${UPGRADE_SCRIPT}"

# ------------------------------------------------------------------------------
# CRON
# ------------------------------------------------------------------------------

echo "=== Configuring automatic system upgrades ==="

CRON_SCHEDULE="17 3 * * 0"
CRON_ENTRY="${CRON_SCHEDULE} root ${UPGRADE_SCRIPT}"

# Remove previous Kito upgrade entries and install exactly one.
sed -i "\|${UPGRADE_SCRIPT}|d" /etc/crontab

echo "${CRON_ENTRY}" >> /etc/crontab

# ------------------------------------------------------------------------------
# CRON SERVICE
# ------------------------------------------------------------------------------

echo "=== Enabling cron ==="

systemctl enable --now cron

systemctl reload cron 2>/dev/null || true

# ------------------------------------------------------------------------------
# INITIAL SYSTEM UPGRADE
# ------------------------------------------------------------------------------

echo "=== Running initial system upgrade ==="

"${UPGRADE_SCRIPT}"

echo "=== System configuration completed ==="