#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-istoreos-fn}"
IMAGE_TAG="${IMAGE_TAG:-minimal-v1}"
DOCKERFILE="${DOCKERFILE:-Dockerfile.minimal}"
WORKDIR="${WORKDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

cd "$WORKDIR"

echo "[build] workdir: $WORKDIR"
echo "[build] dockerfile: $DOCKERFILE"
echo "[build] image: $FULL_IMAGE"

docker build -f "$DOCKERFILE" -t "$FULL_IMAGE" .

echo "[build] done: $FULL_IMAGE"
