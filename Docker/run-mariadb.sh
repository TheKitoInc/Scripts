#!/bin/bash

INSTANCE="$1"
PORT="$2"
ROOT_PASSWORD_HASH="$3"

if [[ -z "$INSTANCE" || -z "$PORT" || -z "$ROOT_PASSWORD_HASH" ]]; then
  echo "Usage: $0 <instance-name> <host-port> <root-password-hash>"
  echo "To generate hash: mysql -NBe \"SELECT PASSWORD('yourpassword');\""
  exit 1
fi

docker run -d --rm \
  --name "mariadb_${INSTANCE}" \
  -e MARIADB_ROOT_PASSWORD_HASH="${ROOT_PASSWORD_HASH}" \
  -v "mariadb_data_${INSTANCE}":/var/lib/mysql \
  -p "${PORT}:3306" \
  mariadb:11
