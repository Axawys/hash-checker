import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class HashService {
  const HashService();

  Future<String> computeFileHash(String path, String algorithmName) async {
    final digestSink = AccumulatorSink<Digest>();
    late ByteConversionSink input;

    switch (algorithmName) {
      case 'SHA-256':
        input = sha256.startChunkedConversion(digestSink);
        break;
      case 'SHA-512':
        input = sha512.startChunkedConversion(digestSink);
        break;
      case 'SHA-1':
        input = sha1.startChunkedConversion(digestSink);
        break;
      case 'MD5':
        input = md5.startChunkedConversion(digestSink);
        break;
      default:
        throw UnsupportedError('Unknown algorithm: $algorithmName');
    }

    final stream = File(path).openRead();
    await for (final chunk in stream) {
      input.add(chunk);
    }
    input.close();

    return digestSink.events.single.toString();
  }

  Future<String> readTextFile(String path) {
    return File(path).readAsString();
  }

  bool hashesMatch(String calculated, String expected) {
    return calculated.toLowerCase() == expected.toLowerCase();
  }
}
