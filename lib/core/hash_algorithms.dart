const supportedHashAlgorithms = ['SHA-256', 'SHA-512', 'SHA-1', 'MD5'];

String normalizeHashAlgorithmName(String value) {
  return value.toLowerCase().replaceAll('-', '').trim();
}

String? detectHashAlgorithm(String value) {
  final normalizedValue = normalizeHashAlgorithmName(value);

  for (final algorithm in supportedHashAlgorithms) {
    if (normalizeHashAlgorithmName(algorithm) == normalizedValue) {
      return algorithm;
    }
  }

  return null;
}
