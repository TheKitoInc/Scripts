#!/bin/bash

INSTANCE="${1:-default}"
PORT="${2:-9000}"
DATA_VOLUME="portainer_data_${INSTANCE}"
IMAGE="portainer/portainer-ce:latest"

# Check if volume exists
VOLUME_EXISTS=$(docker volume ls -q -f name="^${DATA_VOLUME}$")
DOCKER_ARGS=(--rm --name "portainer_${INSTANCE}" -p "${PORT}:9000" -v "/var/run/docker.sock:/var/run/docker.sock" -v "${DATA_VOLUME}:/data")

if [[ -z "$VOLUME_EXISTS" ]]; then
  echo "📦 Creating volume: $DATA_VOLUME"
  docker volume create "$DATA_VOLUME" >/dev/null

  echo "🔐 Generating random admin password inside a temporary container"

  PASSWORD=$(docker run --rm node:18-alpine sh -c "
    apk add --no-cache openssl >/dev/null &&
    node -e 'console.log(require(\"crypto\").randomBytes(24).toString(\"base64\"))'
  ")

  HASH=$(docker run --rm -i node:18-alpine sh -c "
    npm install bcryptjs >/dev/null 2>&1 &&
    node -e 'const bcrypt=require(\"bcryptjs\"); process.stdin.on(\"data\", d => { const pwd=d.toString().trim(); console.log(bcrypt.hashSync(pwd,10)); });'
  " <<<"$PASSWORD")

  echo "🔐 Admin password for '${INSTANCE}':"
  echo "$PASSWORD"

  # Write hash to volume
  docker run --rm -v "${DATA_VOLUME}:/data" alpine sh -c "echo '$HASH' > /data/portainer-password"
else
  echo "📦 Volume ${DATA_VOLUME} already exists — skipping init"
fi

echo "🚀 Starting Portainer '${INSTANCE}' on port ${PORT}"
docker run "${DOCKER_ARGS[@]}" "$IMAGE"
