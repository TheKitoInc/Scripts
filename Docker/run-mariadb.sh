#!/bin/bash

INSTANCE="$1"
PORT="$2"
DATA_VOLUME="mariadb_data_${INSTANCE}"
IMAGE="mariadb:latest"

if [[ -z "$INSTANCE" || -z "$PORT" ]]; then
  echo "Usage: $0 <instance-name> <host-port>"
  exit 1
fi

# Check if volume already exists
VOLUME_EXISTS=$(docker volume ls -q -f name="^${DATA_VOLUME}$")

if [[ -z "$VOLUME_EXISTS" ]]; then
  echo "No data volume found, initializing MariaDB volume: $DATA_VOLUME"

  # Generate random root password
  ROOT_PASSWORD=$(openssl rand -base64 32)
  echo "New MariaDB root password for '${INSTANCE}':"
  echo "$ROOT_PASSWORD"

  # Create and initialize volume in a temporary container
  docker run --rm \
    --name "mariadb_init_${INSTANCE}" \
    -e MARIADB_ROOT_PASSWORD="$ROOT_PASSWORD" \
    -v "${DATA_VOLUME}":/var/lib/mysql \
    $IMAGE \
    --log-bin=mysqld-bin --binlog-format=ROW

  echo "MariaDB volume initialized and container exited"
else
  echo "Volume ${DATA_VOLUME} already exists — skipping init"
fi

# Start the persistent container (no password env needed)
echo "Starting MariaDB container '${INSTANCE}' on port ${PORT}"
docker run -d --rm \
  --name "mariadb_${INSTANCE}" \
  -v "${DATA_VOLUME}":/var/lib/mysql \
  -p "${PORT}:3306" \
  $IMAGE
