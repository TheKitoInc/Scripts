#!/usr/bin/env bash
set -Eeuo pipefail

################################################################################
# build-image.sh
#
# Build Docker images from git repositories, and make sure a container is
# running the freshly built image. Crash recovery is handled by Docker
# itself (--restart unless-stopped); redeploys to a new image are handled
# by this script re-running with a fresh --network + docker run.
#
# Usage:
#   build-image.sh /path/to/repository
################################################################################

export DOCKER_BUILDKIT=1

[[ $# -eq 1 ]] || {
    echo "Usage: $0 <git repository>"
    exit 1
}

REPO="$(realpath "$1")"

[[ -d "$REPO/.git" ]] || {
    echo "Not a git repository: $REPO"
    exit 1
}

[[ -f "$REPO/Dockerfile" ]] || {
    echo "No Dockerfile found in $REPO"
    exit 1
}

# Allow Git to operate on this repository even when ownership differs,
# without permanently touching the invoking user's global ~/.gitconfig.
# Scoped via env vars so it only applies to git calls made by this script.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=safe.directory
export GIT_CONFIG_VALUE_0="$REPO"

cd "$REPO"

###############################################################################
# Git metadata
###############################################################################

IMAGE="$(basename "$PWD")"

# Docker-safe version of the image name: lowercase, invalid chars -> '-'.
# Used everywhere a Docker reference (tag / images filter / container name)
# is needed, so build, cleanup and the container check always agree.
IMAGE_SAFE="$(echo "$IMAGE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g')"

###############################################################################
# Lock: serialize concurrent runs against the same image (e.g. two runs of a
# `find ... -exec build-image.sh {}` sweep landing on the same repo).
# Different repos still run in parallel - one lock file per image. Held for
# the rest of the script, so it also covers the container-ensure step below.
###############################################################################

LOCK_DIR="/var/lock/build-image"
mkdir -p "$LOCK_DIR"
exec 9>"$LOCK_DIR/${IMAGE_SAFE}.lock"
flock 9

SHA="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short=12 HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
REMOTE="$(git config --get remote.origin.url || true)"
DESCRIBE="$(git describe --always --tags --dirty 2>/dev/null || echo "$SHORT_SHA")"

TAG="${SHORT_SHA}"
IMAGE_HASH="${IMAGE_SAFE}:${TAG}"

# Track whether the working tree is dirty; used both for the "latest" vs
# "dirty" tag and to decide whether a previous build can be trusted.
if git diff-index --quiet HEAD --; then
    IS_DIRTY=0
    IMAGE_LATEST="${IMAGE_SAFE}:latest"
else
    IS_DIRTY=1
    IMAGE_LATEST="${IMAGE_SAFE}:dirty"
fi

BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

###############################################################################
# Build (skipped only if this exact commit was already built AND the tree is
# clean - a dirty tree always rebuilds, see IS_DIRTY above). If the build
# fails, `set -e` aborts here and the running container is left untouched.
###############################################################################

if [[ "$IS_DIRTY" -eq 0 ]] && docker image inspect "$IMAGE_HASH" >/dev/null 2>&1; then
    echo
    echo "Already built:"
    echo "  $IMAGE_HASH"

    CURRENT_ID="$(docker image inspect "$IMAGE_HASH" --format '{{.Id}}')"
else
    docker build \
        --progress=plain \
        --pull \
        \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg GIT_SHA="$SHA" \
        --build-arg GIT_SHA_SHORT="$SHORT_SHA" \
        --build-arg GIT_BRANCH="$BRANCH" \
        --build-arg GIT_DESCRIBE="$DESCRIBE" \
        --label org.opencontainers.image.title="$IMAGE" \
        --label org.opencontainers.image.description="$IMAGE container image" \
        --label org.opencontainers.image.version="$TAG" \
        --label org.opencontainers.image.revision="$SHA" \
        --label org.opencontainers.image.created="$BUILD_DATE" \
        --label org.opencontainers.image.source="$REMOTE" \
        --label org.opencontainers.image.url="$REMOTE" \
        --label org.opencontainers.image.ref.name="$BRANCH" \
        --label org.opencontainers.image.vendor="Local Build" \
        --label org.opencontainers.image.authors="$(git config user.name 2>/dev/null || true)" \
        --label org.opencontainers.image.licenses="UNLICENSED" \
        \
        -t "$IMAGE_HASH" \
        -t "$IMAGE_LATEST" \
        .

    CURRENT_ID="$(docker image inspect "$IMAGE_HASH" --format '{{.Id}}')"

    ###########################################################################
    # Cleanup old images (for this repo only)
    ###########################################################################

    # --no-trunc: docker images' {{.ID}} is normally the short 12-char form,
    # but $CURRENT_ID above is the full sha256:... form - without --no-trunc
    # these never match, so the image just built gets deleted right here.
    docker images "$IMAGE_SAFE" --no-trunc \
        --format '{{.Repository}} {{.Tag}} {{.ID}}' |
    while read -r IMG_REPO IMG_TAG IMG_ID
    do
        [[ "$IMG_ID" == "$CURRENT_ID" ]] && continue
        [[ "$IMG_TAG" == "latest" ]] && continue
        [[ "$IMG_TAG" == "<none>" ]] && continue

        if docker ps -aq --filter ancestor="$IMG_ID" | grep -q .; then
            echo "Keeping ${IMG_REPO}:${IMG_TAG} (container exists)"
            continue
        fi

        echo "Removing ${IMG_REPO}:${IMG_TAG}"
        docker image rm "${IMG_REPO}:${IMG_TAG}" >/dev/null 2>&1 || true
    done
fi

###############################################################################
# Shared network: containers resolve each other by container name over this
# user-defined network (Docker's *default* bridge network does NOT do name
# resolution - only a user-defined one does). No ports are published to the
# host; calls between services happen container-name-to-container-name here.
###############################################################################

NETWORK_NAME="blk-net"
docker network inspect "$NETWORK_NAME" >/dev/null 2>&1 || docker network create "$NETWORK_NAME" >/dev/null

###############################################################################
# Ports: only published to the host if the Dockerfile declares them via
# EXPOSE. Most internal microservices have no EXPOSE and stay reachable
# only over $NETWORK_NAME - "door" services (nginx-style gateways etc.)
# that do declare EXPOSE get that port published automatically. Handles
# multiple EXPOSE lines, multiple ports per line, and an optional
# /tcp or /udp suffix. ARG-based EXPOSE values can't be resolved here and
# are skipped.
###############################################################################

PUBLISH_FLAGS=()
while IFS= read -r PORT_SPEC; do
    PUBLISH_FLAGS+=(-p "${PORT_SPEC%%/*}:${PORT_SPEC}")
done < <(grep -iE '^[[:space:]]*EXPOSE[[:space:]]' "$REPO/Dockerfile" \
    | sed -E 's/^[[:space:]]*EXPOSE[[:space:]]+//I' \
    | tr -s '[:space:]' '\n' \
    | grep -E '^[0-9]+(/(tcp|udp))?$')

if [[ "${#PUBLISH_FLAGS[@]}" -gt 0 ]]; then
    echo "Dockerfile declares EXPOSE - publishing: ${PUBLISH_FLAGS[*]}"
else
    echo "No EXPOSE in Dockerfile - internal only, no ports published"
fi

###############################################################################
# Ensure a container is running the current image. If it's not running, or
# it's running an older image, kill it and launch a new one.
#
# NOTE: no env/volumes beyond the shared network and any EXPOSE-derived
# ports above. If this specific project needs more, extend the
# `docker run` line below for it.
#
# --restart unless-stopped: Docker restarts it automatically on crash or
# VPS reboot, but leaves it alone if it was stopped on purpose (docker stop).
# (Combining --restart with --rm is not allowed by Docker, so this container
# is no longer self-removing - the docker rm -f below is what replaces it.)
###############################################################################

CONTAINER_NAME="${IMAGE_SAFE}"

STATE="$(docker inspect --format '{{.State.Running}}:{{.Image}}' "$CONTAINER_NAME" 2>/dev/null || echo "false:")"
IS_RUNNING="${STATE%%:*}"
RUNNING_IMAGE_ID="${STATE#*:}"

if [[ "$IS_RUNNING" != "true" || "$RUNNING_IMAGE_ID" != "$CURRENT_ID" ]]; then
    if [[ "$IS_RUNNING" == "true" ]]; then
        echo "Container $CONTAINER_NAME is running an older image - replacing"
    else
        echo "Container $CONTAINER_NAME is not running - starting"
    fi

    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

    docker run -d \
        --restart unless-stopped \
        --name "$CONTAINER_NAME" \
        --network "$NETWORK_NAME" \
        "${PUBLISH_FLAGS[@]}" \
        "$IMAGE_HASH"


    echo "Started $CONTAINER_NAME from $IMAGE_HASH (network: $NETWORK_NAME)"
else
    echo "Container $CONTAINER_NAME already running the current image ($CURRENT_ID)"
fi

###############################################################################
# Summary
###############################################################################

echo
docker image inspect "$IMAGE_HASH" --format '
Image:      {{index .RepoTags 0}}
Image ID:   {{.Id}}

Created:    {{index .Config.Labels "org.opencontainers.image.created"}}
Revision:   {{index .Config.Labels "org.opencontainers.image.revision"}}
Version:    {{index .Config.Labels "org.opencontainers.image.version"}}
Branch:     {{index .Config.Labels "org.opencontainers.image.ref.name"}}
Source:     {{index .Config.Labels "org.opencontainers.image.source"}}
'
