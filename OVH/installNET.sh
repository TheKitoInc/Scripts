#!/usr/bin/env bash

set -Eeuo pipefail

################################################################################
# OVH Debian 13 network configuration
#
# Automatically detects the currently active network configuration and
# persists it using ifupdown + Supervisor.
################################################################################


################################################################################
# Check privileges
################################################################################

echo "=== Checking privileges ==="

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive


################################################################################
# Install required packages
################################################################################

echo "=== Installing required packages ==="

apt-get update

apt-get install -y \
    iproute2 \
    ifupdown \
    supervisor


################################################################################
# Detect current network configuration
################################################################################

echo "=== Detecting current network configuration ==="

NIC="$(ip route show default | awk 'NR==1 {print $5}')"

if [[ -z "$NIC" ]]; then
    echo "ERROR: Could not detect default network interface."
    exit 1
fi

IPv4="$(
    ip -4 addr show dev "$NIC" |
    awk '/inet / && $2 !~ /^127\./ {print $2; exit}' |
    cut -d/ -f1
)"

IPv4GW="$(ip -4 route show default | awk 'NR==1 {print $3}')"

IPv6="$(
    ip -6 addr show dev "$NIC" |
    awk '/inet6 / && $2 !~ /^fe80:/ {print $2; exit}' |
    cut -d/ -f1
)"

IPv6GW="$(ip -6 route show default | awk 'NR==1 {print $3}')"


################################################################################
# Validate detected configuration
################################################################################

echo
echo "=== Detected network ==="
echo "Interface : $NIC"
echo "IPv4      : $IPv4"
echo "IPv4 GW   : $IPv4GW"
echo "IPv6      : $IPv6"
echo "IPv6 GW   : $IPv6GW"
echo

if [[ -z "$IPv4" ]]; then
    echo "ERROR: Could not detect IPv4 address."
    exit 1
fi

if [[ -z "$IPv4GW" ]]; then
    echo "ERROR: Could not detect IPv4 gateway."
    exit 1
fi

if [[ -z "$IPv6" ]]; then
    echo "ERROR: Could not detect IPv6 address."
    exit 1
fi

if [[ -z "$IPv6GW" ]]; then
    echo "ERROR: Could not detect IPv6 gateway."
    exit 1
fi


################################################################################
# Paths
################################################################################

INTERFACES_DIR="/etc/network/interfaces.d"
SCRIPTS_DIR="/opt/kito/scripts"

V4_CONFIG="$INTERFACES_DIR/${NIC}-v4"
V6_CONFIG="$INTERFACES_DIR/${NIC}-v6"

NET_SCRIPT="$SCRIPTS_DIR/net-${NIC}.sh"

SUPERVISOR_CONFIG="/etc/supervisor/conf.d/net-${NIC}.conf"


################################################################################
# Expected IPv4 configuration
################################################################################

EXPECTED_V4="auto $NIC
allow-hotplug $NIC
iface $NIC inet static
        address $IPv4
        netmask 255.255.255.255
        post-up /sbin/ip route add $IPv4GW dev $NIC || true
        post-up /sbin/ip route add default via $IPv4GW dev $NIC || true
        pre-down /sbin/ip route del default via $IPv4GW dev $NIC || true
        pre-down /sbin/ip route del $IPv4GW dev $NIC || true"


################################################################################
# Expected IPv6 configuration
################################################################################

EXPECTED_V6="auto $NIC
allow-hotplug $NIC
iface $NIC inet6 static
        address $IPv6/128
        post-up /sbin/ip -6 route add $IPv6GW dev $NIC || true
        post-up /sbin/ip -6 route add default via $IPv6GW dev $NIC || true
        pre-down /sbin/ip -6 route del default via $IPv6GW dev $NIC || true
        pre-down /sbin/ip -6 route del $IPv6GW dev $NIC || true"


################################################################################
# Check if configuration is already correct
################################################################################

echo "=== Checking existing configuration ==="

NETWORK_CONFIG_OK=false

if [[ -f "$V4_CONFIG" ]] &&
   [[ -f "$V6_CONFIG" ]] &&
   cmp -s <(printf '%s\n' "$EXPECTED_V4") "$V4_CONFIG" &&
   cmp -s <(printf '%s\n' "$EXPECTED_V6") "$V6_CONFIG"; then

    NETWORK_CONFIG_OK=true
fi

if [[ "$NETWORK_CONFIG_OK" == true ]]; then
    echo "Network configuration already matches."
    echo "Nothing to do."
    exit 0
fi


################################################################################
# Create directories
################################################################################

echo "=== Creating directories ==="

mkdir -p "$INTERFACES_DIR"
mkdir -p "$SCRIPTS_DIR"


################################################################################
# Write ifupdown configuration
################################################################################

echo "=== Writing ifupdown configuration ==="

printf '%s\n' "$EXPECTED_V4" > "$V4_CONFIG"
printf '%s\n' "$EXPECTED_V6" > "$V6_CONFIG"


################################################################################
# Create network startup script
################################################################################

echo "=== Creating network startup script ==="

cat > "$NET_SCRIPT" <<EOF
#!/usr/bin/env bash

set -Eeuo pipefail

/sbin/ip -4 addr replace $IPv4/32 dev $NIC
/sbin/ip -4 route replace $IPv4GW dev $NIC
/sbin/ip -4 route replace default via $IPv4GW dev $NIC

/sbin/ip -6 addr replace $IPv6/128 dev $NIC
/sbin/ip -6 route replace $IPv6GW dev $NIC
/sbin/ip -6 route replace default via $IPv6GW dev $NIC
EOF

chmod +x "$NET_SCRIPT"


################################################################################
# Disable cloud-init network configuration
################################################################################

echo "=== Disabling cloud-init network configuration ==="

mkdir -p /etc/cloud/cloud.cfg.d

printf '%s\n' \
    "network: {config: disabled}" \
    > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

rm -f /etc/network/interfaces.d/50-cloud-init


################################################################################
# Configure DNS
################################################################################

echo "=== Configuring DNS ==="

rm -f /etc/resolv.conf

printf '%s\n' "nameserver 1.1.1.1" > /etc/resolv.conf


################################################################################
# Configure Supervisor
################################################################################

echo "=== Configuring Supervisor ==="

cat > "$SUPERVISOR_CONFIG" <<EOF
[program:net-$NIC]
command=$NET_SCRIPT
autostart=true
autorestart=false
startsecs=0
EOF


################################################################################
# Start Supervisor
################################################################################

echo "=== Starting Supervisor ==="

systemctl enable --now supervisor

supervisorctl reread
supervisorctl update


################################################################################
# Done
################################################################################

echo
echo "=== Network configuration completed ==="
echo
echo "Interface : $NIC"
echo "IPv4      : $IPv4"
echo "IPv4 GW   : $IPv4GW"
echo "IPv6      : $IPv6"
echo "IPv6 GW   : $IPv6GW"
echo
