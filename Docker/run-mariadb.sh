#!/bin/bash

INSTANCE="${1:-default}"
PORT="${2:-3306}"
DATA_VOLUME="mariadb_data_${INSTANCE}"
IMAGE="mariadb:latest"

# Check if volume exists
VOLUME_EXISTS=$(docker volume ls -q -f name="^${DATA_VOLUME}$")
DOCKER_ARGS=(--rm --name "mariadb_${INSTANCE}" -v "${DATA_VOLUME}:/var/lib/mysql" -p "${PORT}:3306")

if [[ -z "$VOLUME_EXISTS" ]]; then
  echo "📦 No data volume found, initializing MariaDB volume: $DATA_VOLUME"
  docker volume create "$DATA_VOLUME" >/dev/null

  ROOT_PASSWORD=$(openssl rand -base64 32)
  echo "🔐 New MariaDB root password for '${INSTANCE}':"
  echo "$ROOT_PASSWORD"
  DOCKER_ARGS+=(-e "MARIADB_ROOT_PASSWORD=${ROOT_PASSWORD}")
else
  echo "📦 Volume ${DATA_VOLUME} already exists — skipping init"
  # Don't add env vars — MariaDB ignores them on existing volume
fi

echo "🚀 Starting MariaDB container '${INSTANCE}' on port ${PORT}"
docker run "${DOCKER_ARGS[@]}" "$IMAGE"
