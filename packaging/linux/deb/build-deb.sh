#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
image_name="${IMAGE_NAME:-hashchecker-deb-builder:ubuntu-24.04}"
engine="${CONTAINER_ENGINE:-}"
volume_suffix="${VOLUME_SUFFIX:-}"
user_args=(--user "$(id -u):$(id -g)")

if [[ -z "$engine" ]]; then
  if command -v docker >/dev/null 2>&1; then
    engine="docker"
  elif command -v podman >/dev/null 2>&1; then
    engine="podman"
    volume_suffix="${volume_suffix:-:Z}"
  else
    echo "Docker or Podman is required." >&2
    exit 1
  fi
fi

"$engine" build \
  -f "$repo_root/packaging/linux/deb/Dockerfile" \
  -t "$image_name" \
  "$repo_root"

"$engine" run --rm \
  "${user_args[@]}" \
  -e HOME=/tmp \
  -e PUB_CACHE=/tmp/pub-cache \
  -e FLUTTER_SUPPRESS_ANALYTICS=true \
  -v "$repo_root:/work$volume_suffix" \
  -w /work \
  "$image_name" \
  bash packaging/linux/deb/package-in-container.sh
