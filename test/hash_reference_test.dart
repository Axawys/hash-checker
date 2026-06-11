import 'package:flutter_test/flutter_test.dart';
import 'package:hashchecker/core/hash_reference.dart';

void main() {
  test('parses a hash with an algorithm prefix', () {
    final hash = 'a' * 64;
    final reference = parseHashReference('sha256: ${hash.toUpperCase()}', 'Буфер');

    expect(reference?.hash, hash);
    expect(reference?.detectedAlgorithm, 'SHA-256');
    expect(reference?.subtitle, 'Буфер: aaaaaa...aaaaaa');
  });

  test('parses the first token from checksum file format', () {
    final hash = 'b' * 64;
    final reference = parseHashReference(
      '$hash  installer.iso',
      'checksum.txt',
    );

    expect(reference?.hash, hash);
    expect(reference?.detectedAlgorithm, 'SHA-256');
  });

  test('detects algorithm by hash length', () {
    final reference = parseHashReference('a' * 64, 'Clipboard');

    expect(reference?.hash, 'a' * 64);
    expect(reference?.detectedAlgorithm, 'SHA-256');
  });

  test('rejects short values', () {
    expect(parseHashReference('abc123', 'Буфер'), isNull);
  });

  test('rejects non-hex values', () {
    expect(parseHashReference('фффффффф', 'Буфер'), isNull);
  });

  test('rejects unsupported hash lengths', () {
    expect(parseHashReference('a' * 16, 'Буфер'), isNull);
  });

  test('rejects hash when prefix and length disagree', () {
    expect(parseHashReference('sha256: ${'a' * 32}', 'Буфер'), isNull);
  });
}
