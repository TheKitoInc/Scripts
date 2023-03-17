#!/bin/bash
groupadd -g 5000 vmail 
useradd -g vmail -u 5000 vmail -d /var/mail/maildir -m
mkdir -p "/var/mail/maildir"
echo "
mail_location = maildir:/var/mail/maildir/%d/%n
namespace inbox {
	inbox = yes
}
mail_privileged_group = mail
mbox_write_locks = fcntl
" > /etc/dovecot/conf.d/10-mail.conf
