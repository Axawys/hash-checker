import 'hash_algorithms.dart';

class HashReference {
  const HashReference({
    required this.hash,
    required this.sourceDisplayName,
    this.detectedAlgorithm,
  });

  final String hash;
  final String sourceDisplayName;
  final String? detectedAlgorithm;

  String get shortHash {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 6)}';
  }

  String get subtitle => '$sourceDisplayName: $shortHash';
}

HashReference? parseHashReference(String? rawText, String sourceDisplayName) {
  if (rawText == null || rawText.trim().isEmpty) return null;

  final cleanText = rawText.trim();
  var hash = cleanText;
  String? detectedAlgorithm;

  if (cleanText.contains(':')) {
    final parts = cleanText.split(':');
    if (parts.length >= 2) {
      final algorithm = detectHashAlgorithm(parts.first);
      if (algorithm != null) {
        detectedAlgorithm = algorithm;
        hash = parts.sublist(1).join(':').trim();
      }
    }
  }

  hash = hash.split(RegExp(r'\s+')).first.toLowerCase();

  if (!isSupportedHashValue(hash, detectedAlgorithm: detectedAlgorithm)) {
    return null;
  }

  detectedAlgorithm ??= detectHashAlgorithmByHashLength(hash);

  return HashReference(
    hash: hash,
    sourceDisplayName: sourceDisplayName,
    detectedAlgorithm: detectedAlgorithm,
  );
}

bool isSupportedHashValue(String value, {String? detectedAlgorithm}) {
  final hash = value.trim().toLowerCase();
  if (!RegExp(r'^[0-9a-f]+$').hasMatch(hash)) return false;

  final algorithmByLength = detectHashAlgorithmByHashLength(hash);
  if (algorithmByLength == null) return false;

  return detectedAlgorithm == null || detectedAlgorithm == algorithmByLength;
}
