#!/usr/bin/env bash
set -euo pipefail

archive_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
install_dir="$data_home/hashchecker"
bin_dir="$HOME/.local/bin"
apps_dir="$data_home/applications"
icons_dir="$data_home/icons/hicolor/256x256/apps"
desktop_id="io.github.axawys.HashChecker"
desktop_file="$apps_dir/$desktop_id.desktop"
icon_file="$icons_dir/$desktop_id.png"
legacy_desktop_file="$apps_dir/hashchecker.desktop"
legacy_icon_file="$icons_dir/hashchecker.png"

mkdir -p "$install_dir" "$bin_dir" "$apps_dir" "$icons_dir"

rm -rf "$install_dir/lib" "$install_dir/share" "$install_dir/hashchecker"
cp -a "$archive_dir/lib" "$install_dir/lib"
cp -a "$archive_dir/share" "$install_dir/share"
cp "$archive_dir/hashchecker" "$install_dir/hashchecker"

chmod 755 "$install_dir/hashchecker"
chmod 755 "$install_dir/lib/hashchecker/hashchecker"
chmod 755 "$install_dir/lib/hashchecker/lib/libapp.so"
chmod 755 "$install_dir/lib/hashchecker/lib/libfile_selector_linux_plugin.so"
chmod 755 "$install_dir/lib/hashchecker/lib/libflutter_linux_gtk.so"

ln -sfn "$install_dir/hashchecker" "$bin_dir/hashchecker"
cp "$install_dir/share/icons/hicolor/256x256/apps/$desktop_id.png" "$icon_file"
cp "$install_dir/share/icons/hicolor/256x256/apps/hashchecker.png" "$legacy_icon_file"

cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=HashChecker
Comment=Check file hashes
Exec=$install_dir/hashchecker
Icon=$icon_file
Terminal=false
Categories=Utility;
StartupWMClass=$desktop_id
EOF

rm -f "$legacy_desktop_file"
chmod 644 "$desktop_file" "$icon_file" "$legacy_icon_file"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$data_home/icons/hicolor" >/dev/null 2>&1 || true
fi

cat <<EOF
HashChecker installed.

Run it with:
  $bin_dir/hashchecker

If your shell cannot find it, add this to your PATH:
  $bin_dir
EOF
