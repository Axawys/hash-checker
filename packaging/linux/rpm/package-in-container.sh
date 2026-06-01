#!/usr/bin/env bash
set -euo pipefail

version_value="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
app_version="${version_value%%+*}"
build_number="${version_value#*+}"
if [[ "$build_number" == "$version_value" ]]; then
  build_number="1"
fi

package_root="/tmp/hashchecker-rpm-root"
bundle_dir="build/linux/x64/release/bundle"
package_path="dist/hashchecker-${app_version}-${build_number}.x86_64.rpm"
desktop_id="io.github.axawys.HashChecker"

git config --global --add safe.directory /opt/flutter

flutter pub get
rm -rf build/linux
flutter build linux --release

rm -rf "$package_root"
mkdir -p "$package_root/usr/lib64/hashchecker"
mkdir -p "$package_root/usr/bin"
mkdir -p "$package_root/usr/share/applications"
mkdir -p "$package_root/usr/share/icons/hicolor/256x256/apps"
mkdir -p dist

cp -a "$bundle_dir/." "$package_root/usr/lib64/hashchecker/"
cp packaging/linux/rpm/hashchecker.desktop "$package_root/usr/share/applications/$desktop_id.desktop"
cp assets/icon.png "$package_root/usr/share/icons/hicolor/256x256/apps/$desktop_id.png"
cp assets/icon.png "$package_root/usr/share/icons/hicolor/256x256/apps/hashchecker.png"
ln -s /usr/lib64/hashchecker/hashchecker "$package_root/usr/bin/hashchecker"

chmod 755 "$package_root/usr/lib64/hashchecker/hashchecker"
chmod 755 "$package_root/usr/lib64/hashchecker/lib/libapp.so"
chmod 755 "$package_root/usr/lib64/hashchecker/lib/libfile_selector_linux_plugin.so"
chmod 755 "$package_root/usr/lib64/hashchecker/lib/libflutter_linux_gtk.so"
chmod 644 "$package_root/usr/share/applications/$desktop_id.desktop"
chmod 644 "$package_root/usr/share/icons/hicolor/256x256/apps/$desktop_id.png"
chmod 644 "$package_root/usr/share/icons/hicolor/256x256/apps/hashchecker.png"

desktop-file-validate "$package_root/usr/share/applications/$desktop_id.desktop"

rm -f "$package_path"

fpm -s dir -t rpm \
  -n hashchecker \
  -v "$app_version" \
  --iteration "$build_number" \
  -a x86_64 \
  --description "File hash checker" \
  --url https://github.com/Axawys/hash-checker \
  --license MIT \
  --maintainer Axawys \
  --depends gtk3 \
  -C "$package_root" \
  -p "$package_path" \
  .

rpm -qip "$package_path"
rpm -qlp "$package_path"
