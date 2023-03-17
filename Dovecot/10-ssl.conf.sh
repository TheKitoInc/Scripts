#!/bin/bash
apt-get install ssl-cert -y
make-ssl-cert generate-default-snakeoil
echo "
ssl = required
ssl_cert = </etc/ssl/certs/ssl-cert-snakeoil.pem
ssl_key = </etc/ssl/private/ssl-cert-snakeoil.key
" > /etc/dovecot/conf.d/10-ssl.conf
