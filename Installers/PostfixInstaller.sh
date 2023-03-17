#!/bin/bash
echo "

#Relay
fallback_relay = $(cat /etc/mailname)

#SMTP Client
smtp_tls_security_level = may
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/smtp_sasl_password_maps
smtp_sasl_security_options = noanonymous
smtp_extra_recipient_limit = 5
smtp_destination_rate_delay = 1s
smtp_destination_concurrency_limit = 1

#SMTP Server
smtpd_use_tls = yes
smtpd_tls_cert_file = /etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key

#Headers
mime_header_checks = regexp:/etc/postfix/header_checks
header_checks = regexp:/etc/postfix/header_checks

#inet_protocols = ipv4
myhostname = $(cat /etc/hostname)
smtpd_banner = \$myhostname ESMTP $mail_name
biff = no
append_dot_mydomain = no
myorigin = /etc/mailname

compatibility_level = 2
soft_bounce = yes
bounce_queue_lifetime = 0
message_size_limit = 26214400

mynetworks = /etc/postfix/mynetworks
mydestination = /etc/postfix/mydestination

transport_maps = hash:/etc/postfix/transport_maps

virtual_alias_domains = /etc/postfix/virtual_alias_domains
virtual_alias_maps = hash:/etc/postfix/virtual_alias_maps

#RBL
smtpd_recipient_restrictions =
            permit_mynetworks,
            permit_sasl_authenticated,
            reject_invalid_hostname,
            reject_unknown_recipient_domain,
            reject_unauth_pipelining,
            reject_unknown_reverse_client_hostname,
            reject_unauth_destination,
            reject_rbl_client dyna.spamrats.com,
            reject_rbl_client noptr.spamrats.com,
            reject_rbl_client spam.spamrats.com,
            reject_rbl_client auth.spamrats.com,
            permit



" > /etc/postfix/main.cf

echo "
127.0.0.0/8
[::ffff:127.0.0.0]/104
[::1]/128
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
" > /etc/postfix/mynetworks

echo "
localhost
localhost.localdomain
" > /etc/postfix/mydestination

echo "
/^Received:/    IGNORE
/^User-Agent:/  IGNORE
/^X-Mailer:/    IGNORE
/^X-MimeOLE:/   IGNORE
/^X-MSMail-Priority:/   IGNORE
/^X-Spam-Status:/       IGNORE
/^X-Spam-Level:/        IGNORE
/^X-Sanitizer:/ IGNORE
/^X-Originating-IP:/    IGNORE
/^X-*:/ IGNORE
" > /etc/postfix/header_checks
postmap /etc/postfix/header_checks

touch /etc/postfix/smtp_sasl_password_maps
postmap /etc/postfix/smtp_sasl_password_maps

touch /etc/postfix/transport_maps
postmap /etc/postfix/transport_maps

touch /etc/postfix/virtual_alias_domains
#postmap /etc/postfix/virtual_alias_domains

touch /etc/postfix/virtual_alias_maps
postmap /etc/postfix/virtual_alias_maps

/etc/init.d/postfix reload
