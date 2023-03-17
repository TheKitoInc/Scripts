#!/bin/bash
echo "
http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	# server_tokens off;
	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	log_format main '\$http_x_forwarded_for - \$remote_user [\$time_local] \"\$host\" \"\$request\" ' '\$status \$body_bytes_sent \"\$http_referer\" ' '\"\$http_user_agent\" \$request_time';
	access_log /var/log/nginx/access.log main;
	error_log /var/log/nginx/error.log;

	gzip on;
	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	proxy_cache_path  /tmp/ng_cache/  levels=1:2 keys_zone=my_cache:10m max_size=10g  inactive=60m use_temp_path=off;

	upstream backend {
		server a.https.$(hostname -d):443;
		server b.https.$(hostname -d):443;
		server c.https.$(hostname -d):443;
		server d.https.$(hostname -d):443;
	}

	server {
		listen 80;
		listen [::]:80;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
		ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
		ssl_session_cache shared:SSL:1m; # holds approx 4000 sessions
		ssl_session_timeout 1h; # 1 hour during which sessions can be re-used.
		# ssl_session_tickets off;

		ssl_buffer_size 1k;

		client_max_body_size 250M;

		location / {

			proxy_cache_key \$scheme\$host\$uri\$is_args\$args;
			proxy_cache my_cache;
			proxy_cache_valid 200 301 302 1d;

			proxy_pass https://backend;

			proxy_set_header Host \$host;
			proxy_set_header X-Real-IP \$remote_addr;
			proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
			proxy_set_header X-Forwarded-Proto \$scheme;

			proxy_buffering on;
		}
	}
}
"
