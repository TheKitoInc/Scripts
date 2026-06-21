#!/bin/bash

set -euo pipefail

command -v docker >/dev/null 2>&1 || {
    echo "[ERROR] Docker not installed"
    exit 1
}

REPO_PATH="${1:-}"

if [ -z "$REPO_PATH" ]; then
    echo "Usage: $0 /path/to/repo"
    exit 1
fi

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Not a git repository: $REPO_PATH"
    exit 1
fi

if [ ! -f "$REPO_PATH/Dockerfile" ]; then
    echo "[ERROR] Dockerfile not found"
    exit 1
fi

# 1. Image name = folder name
IMAGE_NAME=$(basename "$REPO_PATH")

# 2. Get git HEAD (short version for tagging)
SHA=$(git -C "$REPO_PATH" rev-parse --short=8 HEAD)

VERSION_IMAGE="${IMAGE_NAME}:${SHA}"
LATEST_IMAGE="${IMAGE_NAME}:latest"

echo "==================================="
echo "Repo      : $REPO_PATH"
echo "Service   : $IMAGE_NAME"
echo "Commit    : $SHA"
echo "Image     : $VERSION_IMAGE"
echo "==================================="

# 3. Check if image exists
if docker image inspect "$VERSION_IMAGE" >/dev/null 2>&1; then
    echo "[SKIP] Image already exists: $VERSION_IMAGE"
else
    echo "[BUILD] Building $VERSION_IMAGE"
    docker build -t "$VERSION_IMAGE" "$REPO_PATH"
fi

docker tag "$VERSION_IMAGE" "$LATEST_IMAGE"

echo "[OK] Latest -> $VERSION_IMAGE"
echo "Done."
