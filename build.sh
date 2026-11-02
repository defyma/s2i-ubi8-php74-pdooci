#!/usr/bin/env bash
# Build & push defyma/s2i-ubi8-php74-pdooci
# Pakai: ./build.sh [UBI_TAG]   (default: 1792860909)
set -euo pipefail
cd "$(dirname "$0")"
UBI_TAG="${1:-1792860909}"
IMAGE=defyma/s2i-ubi8-php74-pdooci
docker build --platform linux/amd64 --pull \
  --build-arg UBI_TAG="$UBI_TAG" \
  -t "$IMAGE:$UBI_TAG" -t "$IMAGE:latest" .
docker run --rm --platform linux/amd64 --entrypoint php "$IMAGE:$UBI_TAG" -m | grep -E '^(oci8|PDO_OCI)$'
docker push "$IMAGE:$UBI_TAG"
docker push "$IMAGE:latest"
