#!/bin/bash

groupadd -g 5000 vmail
useradd -u 5000 -g vmail -s /usr/bin/nologin -d  /var/mail/maildir/ -m vmail

touch /etc/postfix/virtual_mailbox_maps
postmap /etc/postfix/virtual_mailbox_maps

postconf 'virtual_minimum_uid = 1000'
postconf 'virtual_uid_maps = static:5000'
postconf 'virtual_gid_maps = static:5000'
postconf 'virtual_mailbox_limit = 5368709120'
postconf 'virtual_mailbox_base = /var/mail/maildir/'
postconf 'virtual_mailbox_maps = hash:/etc/postfix/virtual_mailbox_maps'
postconf 'virtual_mailbox_domains = $virtual_mailbox_maps'

/etc/init.d/postfix reload
