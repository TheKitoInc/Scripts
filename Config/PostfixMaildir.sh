#!/bin/bash

cat /etc/group  | grep vmail | grep 5000 > /dev/null || groupadd -g 5000 vmail
cat /etc/passwd | grep vmail | grep 5000 > /dev/null || useradd  -u 5000 -g vmail -s /usr/sbin/nologin -d  /var/mail/maildir/ -m vmail

touch /etc/postfix/virtual_mailbox_maps
touch /etc/postfix/virtual_mailbox_domains

cat /etc/postfix/virtual_mailbox_maps | cut -d' ' -f1 | cut -d'@' -f2 | sort | uniq > /etc/postfix/virtual_mailbox_domains

postmap /etc/postfix/virtual_mailbox_maps

postconf 'virtual_minimum_uid = 1000'
postconf 'virtual_uid_maps = static:5000'
postconf 'virtual_gid_maps = static:5000'
postconf 'virtual_mailbox_limit = 5368709120'
postconf 'virtual_mailbox_base = /var/mail/maildir/'
postconf 'virtual_mailbox_maps = hash:/etc/postfix/virtual_mailbox_maps'
postconf 'virtual_mailbox_domains = /etc/postfix/virtual_mailbox_domains'

/etc/init.d/postfix reload
