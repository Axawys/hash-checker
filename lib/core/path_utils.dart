import 'dart:io';

String basename(String path) {
  return path.split(Platform.pathSeparator).where((part) => part.isNotEmpty).last;
}
