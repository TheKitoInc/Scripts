#!/bin/bash

set -e

echo "=== Updating system ==="
apt update -y 
apt upgrade -y

echo "=== Installing base packages ==="
apt install -y ssl-cert
apt install -y nginx 
apt install -y php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip php-bcmath php-intl php-redis

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

echo "Detected PHP version: $PHP_VERSION"

# ----------------------------
# NGINX CONFIG
# ----------------------------

echo "=== Configuring NGINX ==="

cat > /etc/nginx/sites-available/main <<EOF
server {
  listen 80;
  server_name _;
  return 301 https://\$host\$request_uri;
}

server {
  listen 443 ssl http2;
  server_name _;

  root /var/www/html;
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
      fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
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

rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/main /etc/nginx/sites-enabled/

# ----------------------------
# PHP-FPM TUNING
# ----------------------------

echo "=== Tuning PHP-FPM ==="

PHP_POOL="/etc/php/$PHP_VERSION/fpm/pool.d/[www.conf](http://www.conf)"

sed -i "s/^pm = .*/pm = dynamic/" $PHP_POOL
sed -i "s/^pm.max_children = .*/pm.max_children = 25/" $PHP_POOL
sed -i "s/^pm.start_servers = .*/pm.start_servers = 5/" $PHP_POOL
sed -i "s/^pm.min_spare_servers = .*/pm.min_spare_servers = 3/" $PHP_POOL
sed -i "s/^pm.max_spare_servers = .*/pm.max_spare_servers = 8/" $PHP_POOL
sed -i "s/^;pm.max_requests = .*/pm.max_requests = 500/" $PHP_POOL

# ----------------------------
# PHP.INI TUNING
# ----------------------------

echo "=== Tuning PHP ==="

PHP_INI="/etc/php/$PHP_VERSION/fpm/php.ini"

sed -i "s/^memory_limit = .*/memory_limit = 512M/" $PHP_INI
sed -i "s/^max_execution_time = .*/max_execution_time = 120/" $PHP_INI
sed -i "s/^;max_input_vars = .*/max_input_vars = 3000/" $PHP_INI
sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 64M/" $PHP_INI
sed -i "s/^post_max_size = .*/post_max_size = 64M/" $PHP_INI

# ----------------------------
# OPCACHE
# ----------------------------

echo "=== Configuring OPcache ==="

cat > /etc/php/$PHP_VERSION/fpm/conf.d/99-opcache.ini <<EOF
opcache.enable=1
opcache.memory_consumption=192
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=60
EOF

# ----------------------------
# PERMISSIONS
# ----------------------------

echo "=== Setting permissions ==="

chown -R www-data:www-data /var/www
chmod -R 755 /var/www

# ----------------------------
# ENABLE SERVICES
# ----------------------------

echo "=== Restarting services ==="

systemctl restart php$PHP_VERSION-fpm
systemctl restart nginx

systemctl enable nginx
systemctl enable php$PHP_VERSION-fpm
