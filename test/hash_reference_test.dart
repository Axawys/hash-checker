import 'package:flutter_test/flutter_test.dart';
import 'package:hashchecker/core/hash_reference.dart';

void main() {
  test('parses a hash with an algorithm prefix', () {
    final reference = parseHashReference('sha256: ABCDEF1234567890', 'Буфер');

    expect(reference?.hash, 'abcdef1234567890');
    expect(reference?.detectedAlgorithm, 'SHA-256');
    expect(reference?.subtitle, 'Буфер: abcdef1234567890');
  });

  test('parses the first token from checksum file format', () {
    final reference = parseHashReference(
      'abcdef1234567890  installer.iso',
      'checksum.txt',
    );

    expect(reference?.hash, 'abcdef1234567890');
    expect(reference?.detectedAlgorithm, isNull);
  });

  test('detects algorithm by hash length', () {
    final reference = parseHashReference('a' * 64, 'Clipboard');

    expect(reference?.hash, 'a' * 64);
    expect(reference?.detectedAlgorithm, 'SHA-256');
  });

  test('rejects short values', () {
    expect(parseHashReference('abc123', 'Буфер'), isNull);
  });
}
