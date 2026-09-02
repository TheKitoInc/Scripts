#!/usr/bin/env bash
set -e

echo "=== Installing sSMTP ==="

if ! command -v ssmtp >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y ssmtp
fi

echo "=== Detecting hostname ==="

FQDN="$(hostname -f)"

if [ -z "$FQDN" ] || [ "$FQDN" = "localhost" ]; then
    echo "ERROR: Could not determine FQDN" >&2
    exit 1
fi

DOMAIN="${FQDN#*.}"

if [ "$DOMAIN" = "$FQDN" ]; then
    echo "ERROR: Hostname is not an FQDN: $FQDN" >&2
    exit 1
fi

SMTP_RELAY="smtp.$DOMAIN"

echo "FQDN:   $FQDN"
echo "Domain: $DOMAIN"
echo "Relay:  $SMTP_RELAY"

echo "=== Configuring sSMTP ==="

cat > /etc/ssmtp/ssmtp.conf <<EOF
root=postmaster@$DOMAIN
mailhub=$SMTP_RELAY
hostname=$FQDN
FromLineOverride=YES
EOF

chmod 640 /etc/ssmtp/ssmtp.conf

echo "=== Configuring mail aliases ==="

cat > /etc/ssmtp/revaliases <<EOF
root:postmaster@$DOMAIN:$SMTP_RELAY
EOF

chmod 640 /etc/ssmtp/revaliases

echo "=== sSMTP configuration complete ==="
