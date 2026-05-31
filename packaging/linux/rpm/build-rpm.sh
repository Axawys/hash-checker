#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
image_name="${IMAGE_NAME:-hashchecker-rpm-builder:fedora}"
user_args=(--user "$(id -u):$(id -g)")

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required." >&2
  exit 1
fi

docker build \
  -f "$repo_root/packaging/linux/rpm/Dockerfile" \
  -t "$image_name" \
  "$repo_root"

docker run --rm \
  "${user_args[@]}" \
  -e HOME=/tmp \
  -e PUB_CACHE=/tmp/pub-cache \
  -e FLUTTER_SUPPRESS_ANALYTICS=true \
  -v "$repo_root:/work" \
  -w /work \
  "$image_name" \
  bash packaging/linux/rpm/package-in-container.sh
