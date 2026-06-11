const supportedHashAlgorithms = ['SHA-256', 'SHA-512', 'SHA-1', 'MD5'];

const hashAlgorithmLengths = {
  32: 'MD5',
  40: 'SHA-1',
  64: 'SHA-256',
  128: 'SHA-512',
};

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

String? detectHashAlgorithmByHashLength(String value) {
  return hashAlgorithmLengths[value.length];
}
