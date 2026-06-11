import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hashchecker/core/hash_service.dart';

void main() {
  test('emits progress and completed events while hashing a file', () async {
    final tempDir = await Directory.systemTemp.createTemp('hashchecker-test-');
    final file = File('${tempDir.path}/sample.txt');

    try {
      await file.writeAsString('hello');

      final events = await const HashService()
          .computeFileHashWithProgress(file.path, 'SHA-256')
          .toList();

      expect(events.whereType<HashProgress>(), isNotEmpty);
      expect(events.last, isA<HashCompleted>());
      expect(
        (events.last as HashCompleted).hash,
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
