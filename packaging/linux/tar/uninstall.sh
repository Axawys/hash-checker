#!/usr/bin/env bash
set -euo pipefail

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
install_dir="$data_home/hashchecker"
bin_path="$HOME/.local/bin/hashchecker"
desktop_file="$data_home/applications/hashchecker.desktop"
icon_file="$data_home/icons/hicolor/256x256/apps/hashchecker.png"

rm -rf "$install_dir"
rm -f "$bin_path" "$desktop_file" "$icon_file"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$data_home/applications" >/dev/null 2>&1 || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$data_home/icons/hicolor" >/dev/null 2>&1 || true
fi

echo "HashChecker removed."
