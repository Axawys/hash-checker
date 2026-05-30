#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

"$repo_root/packaging/linux/deb/build-deb.sh"
"$repo_root/packaging/linux/rpm/build-rpm.sh"
