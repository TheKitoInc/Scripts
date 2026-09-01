#!/usr/bin/env bash

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

################################################################################
# Helpers
################################################################################

log() {
    echo
    echo "=== $* ==="
}

set_config_value() {
    local file="$1"
    local key="$2"
    local value="$3"

    if grep -qE "^[[:space:];]*${key}[[:space:]]*=" "$file"; then
        sed -i -E \
            "s|^[[:space:];]*${key}[[:space:]]*=.*|${key} = ${value}|" \
            "$file"
    else
        printf '%s = %s\n' "$key" "$value" >> "$file"
    fi
}

################################################################################
# Packages
################################################################################

log "Updating package lists"

apt-get update

log "Installing packages"

apt-get install -y \
    ssl-cert \
    nginx \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-bcmath \
    php-intl \
    php-redis

################################################################################
# PHP
################################################################################

PHP_VERSION="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"

PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
PHP_POOL="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"
PHP_CONF_DIR="/etc/php/${PHP_VERSION}/fpm/conf.d"
PHP_SOCKET="/run/php/${PHP_FPM_SERVICE}.sock"

echo "Detected PHP version: ${PHP_VERSION}"

if [[ ! -f "$PHP_POOL" ]]; then
    echo "ERROR: PHP-FPM pool not found:"
    echo "  $PHP_POOL"
    exit 1
fi

if [[ ! -f "$PHP_INI" ]]; then
    echo "ERROR: PHP-FPM php.ini not found:"
    echo "  $PHP_INI"
    exit 1
fi

################################################################################
# NGINX
################################################################################

log "Configuring NGINX"

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

WEB_ROOT="/var/www/"

cat > /etc/nginx/sites-available/main <<EOF
server {
    listen 80;
    server_name _;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    http2 on;

    server_name _;

    root ${WEB_ROOT}/public;
    index index.php;

    client_max_body_size 64M;

    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHP_SOCKET};
        fastcgi_read_timeout 120;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|svg|webp)$ {
        expires 30d;
        access_log off;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

# This VPS is dedicated to one site.
# Remove Debian's default site and any other enabled sites.
find /etc/nginx/sites-enabled -mindepth 1 -maxdepth 1 -exec rm -f {} +

ln -sfn \
    /etc/nginx/sites-available/main \
    /etc/nginx/sites-enabled/main

################################################################################
# PHP-FPM
################################################################################

log "Tuning PHP-FPM"

set_config_value "$PHP_POOL" "pm" "dynamic"
set_config_value "$PHP_POOL" "pm.max_children" "25"
set_config_value "$PHP_POOL" "pm.start_servers" "5"
set_config_value "$PHP_POOL" "pm.min_spare_servers" "3"
set_config_value "$PHP_POOL" "pm.max_spare_servers" "8"
set_config_value "$PHP_POOL" "pm.max_requests" "500"

################################################################################
# PHP.INI
################################################################################

log "Tuning PHP"

set_config_value "$PHP_INI" "memory_limit" "512M"
set_config_value "$PHP_INI" "max_execution_time" "120"
set_config_value "$PHP_INI" "max_input_vars" "3000"
set_config_value "$PHP_INI" "upload_max_filesize" "64M"
set_config_value "$PHP_INI" "post_max_size" "64M"

################################################################################
# OPcache
################################################################################

log "Configuring OPcache"

cat > "${PHP_CONF_DIR}/99-opcache.ini" <<EOF
opcache.enable=1
opcache.memory_consumption=192
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=60
EOF

################################################################################
# Web root permissions
################################################################################

log "Preparing web root"

mkdir -p "$WEB_ROOT"
mkdir -p "$WEB_ROOT/public"

find "$WEB_ROOT" -type d -exec chmod 755 {} +
find "$WEB_ROOT" -type f -exec chmod 644 {} +

chown -R www-data:www-data "$WEB_ROOT"

################################################################################
# Validate
################################################################################

log "Validating PHP-FPM"

php-fpm"${PHP_VERSION}" -t

log "Validating NGINX"

nginx -t

################################################################################
# Services
################################################################################

log "Enabling services"

systemctl enable nginx
systemctl enable "$PHP_FPM_SERVICE"

log "Restarting PHP-FPM"

systemctl restart "$PHP_FPM_SERVICE"

log "Reloading NGINX"

systemctl reload nginx

################################################################################
# Final status
################################################################################

log "Final status"

systemctl is-active --quiet "$PHP_FPM_SERVICE" \
    && echo "PHP-FPM: OK" \
    || echo "PHP-FPM: FAILED"

systemctl is-active --quiet nginx \
    && echo "NGINX: OK" \
    || echo "NGINX: FAILED"

echo
echo "=== Setup completed ==="
echo "PHP version : ${PHP_VERSION}"
echo "PHP-FPM     : ${PHP_FPM_SERVICE}"
echo "Web root    : ${WEB_ROOT}"
echo "Public root : ${WEB_ROOT}/public"