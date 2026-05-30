#!/usr/bin/env bash
set -euo pipefail

version_value="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
app_version="${version_value%%+*}"
build_number="${version_value#*+}"
if [[ "$build_number" == "$version_value" ]]; then
  build_number="1"
fi

package_root="/tmp/hashchecker-deb-root"
bundle_dir="build/linux/x64/release/bundle"
package_path="dist/hashchecker_${app_version}-${build_number}_amd64.deb"

git config --global --add safe.directory /opt/flutter

flutter pub get
rm -rf build/linux
flutter build linux --release

rm -rf "$package_root"
mkdir -p "$package_root/usr/lib/hashchecker"
mkdir -p "$package_root/usr/bin"
mkdir -p "$package_root/usr/share/applications"
mkdir -p "$package_root/usr/share/icons/hicolor/256x256/apps"
mkdir -p dist

cp -a "$bundle_dir/." "$package_root/usr/lib/hashchecker/"
cp packaging/linux/deb/hashchecker.desktop "$package_root/usr/share/applications/hashchecker.desktop"
cp assets/icon.png "$package_root/usr/share/icons/hicolor/256x256/apps/hashchecker.png"
ln -s /usr/lib/hashchecker/hashchecker "$package_root/usr/bin/hashchecker"

chmod 755 "$package_root/usr/lib/hashchecker/hashchecker"
chmod 755 "$package_root/usr/lib/hashchecker/lib/libapp.so"
chmod 755 "$package_root/usr/lib/hashchecker/lib/libfile_selector_linux_plugin.so"
chmod 755 "$package_root/usr/lib/hashchecker/lib/libflutter_linux_gtk.so"
chmod 644 "$package_root/usr/share/applications/hashchecker.desktop"
chmod 644 "$package_root/usr/share/icons/hicolor/256x256/apps/hashchecker.png"

desktop-file-validate "$package_root/usr/share/applications/hashchecker.desktop"

rm -f "$package_path"

fpm -s dir -t deb \
  -n hashchecker \
  -v "$app_version" \
  --iteration "$build_number" \
  -a amd64 \
  --description "File hash checker" \
  --url https://github.com/Axawys/hash-checker \
  --license MIT \
  --maintainer Axawys \
  --depends libgtk-3-0 \
  -C "$package_root" \
  -p "$package_path" \
  .

dpkg-deb -I "$package_path"
dpkg-deb -c "$package_path"
