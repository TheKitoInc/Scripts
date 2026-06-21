#!/bin/bash

REPO_PATH="$1"

if [ -z "$REPO_PATH" ]; then
    echo "Usage: $0 /path/to/repo"
    exit 1
fi

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Not a git repository: $REPO_PATH"
    exit 1
fi

# 1. Image name = folder name
IMAGE_NAME=$(basename "$REPO_PATH")

# 2. Get git HEAD (short version for tagging)
SHA=$(git -C "$REPO_PATH" rev-parse HEAD | cut -c1-8)

VERSION_IMAGE="${IMAGE_NAME}:${SHA}"
LATEST_IMAGE="${IMAGE_NAME}:latest"

echo "==================================="
echo "Repo      : $REPO_PATH"
echo "Service   : $IMAGE_NAME"
echo "Commit    : $SHA"
echo "Image     : $VERSION_IMAGE"
echo "==================================="

# 3. Check if image exists
if docker image inspect "$VERSION_IMAGE" > /dev/null 2>&1; then
    echo "[SKIP] Image already exists: $VERSION_IMAGE"
else
    echo "[BUILD] Image not found, building..."

    docker build -t "$VERSION_IMAGE" "$REPO_PATH"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Build failed"
        exit 1
    fi

    # Ensure latest points to it
    docker tag "$VERSION_IMAGE" "$LATEST_IMAGE"
    
    echo "[OK] Built $VERSION_IMAGE"
fi

echo "Done."
