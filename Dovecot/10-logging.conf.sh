#!/bin/bash
touch /var/log/dovecot.log
chown dovecot:dovecot /var/log/dovecot.log
chmod 660 /var/log/dovecot.log
echo "
log_path = /var/log/dovecot.log
" > /etc/dovecot/conf.d/10-logging.conf
