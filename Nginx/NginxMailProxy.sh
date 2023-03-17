#!/bin/bash
echo "
mail {
        server_name $(hostname -f);
        auth_http nginx.auth.$(hostname -d);

        proxy_pass_error_message on;
        xclient off;

        ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
        ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
        ssl_session_cache   shared:SSL2:10m;
        ssl_session_timeout 10m;

        starttls on;

        pop3_auth         plain;
        imap_auth         plain;
        smtp_auth         login plain;
        # smtp_auth         login plain cram-md5;
        smtp_capabilities 'SIZE 10485760' ENHANCEDSTATUSCODES 8BITMIME DSN;

        server {
                listen     587;
                listen     [::]:587;
                protocol   smtp;
        }

        server {
                listen     465 ssl;
                listen     [::]:465 ssl;
                protocol   smtp;
        }

        server {
                listen    110;
                listen    [::]:110;
                protocol  pop3;
        }

        server {
                listen    995 ssl;
                listen    [::]:995 ssl;
                protocol  pop3;
        }

        server {
                listen   143;
                listen   [::]:143;
                protocol imap;
        }

        server {
                listen   993 ssl;
                listen   [::]:993 ssl;
                protocol imap;
        }
}
"
