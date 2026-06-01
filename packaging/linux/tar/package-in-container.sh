#!/usr/bin/env bash
set -euo pipefail

version_value="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
app_version="${version_value%%+*}"

package_name="hashchecker-${app_version}-linux-x64"
package_root="/tmp/$package_name"
bundle_dir="build/linux/x64/release/bundle"
package_path="dist/$package_name.tar.gz"
desktop_id="io.github.axawys.HashChecker"

git config --global --add safe.directory /opt/flutter

flutter pub get
rm -rf build/linux
flutter build linux --release

rm -rf "$package_root"
mkdir -p "$package_root/lib/hashchecker"
mkdir -p "$package_root/share/applications"
mkdir -p "$package_root/share/icons/hicolor/256x256/apps"
mkdir -p dist

cp -a "$bundle_dir/." "$package_root/lib/hashchecker/"
cp packaging/linux/tar/hashchecker.launcher "$package_root/hashchecker"
cp packaging/linux/tar/install.sh "$package_root/install.sh"
cp packaging/linux/tar/uninstall.sh "$package_root/uninstall.sh"
cp packaging/linux/tar/hashchecker.desktop "$package_root/share/applications/$desktop_id.desktop"
cp assets/icon.png "$package_root/share/icons/hicolor/256x256/apps/$desktop_id.png"
cp assets/icon.png "$package_root/share/icons/hicolor/256x256/apps/hashchecker.png"

chmod 755 "$package_root/hashchecker"
chmod 755 "$package_root/install.sh"
chmod 755 "$package_root/uninstall.sh"
chmod 755 "$package_root/lib/hashchecker/hashchecker"
chmod 755 "$package_root/lib/hashchecker/lib/libapp.so"
chmod 755 "$package_root/lib/hashchecker/lib/libfile_selector_linux_plugin.so"
chmod 755 "$package_root/lib/hashchecker/lib/libflutter_linux_gtk.so"
chmod 644 "$package_root/share/applications/$desktop_id.desktop"
chmod 644 "$package_root/share/icons/hicolor/256x256/apps/$desktop_id.png"
chmod 644 "$package_root/share/icons/hicolor/256x256/apps/hashchecker.png"

desktop-file-validate "$package_root/share/applications/$desktop_id.desktop"

rm -f "$package_path"
tar --sort=name --owner=0 --group=0 --numeric-owner -C /tmp -czf "$package_path" "$package_name"
tar -tzf "$package_path"
