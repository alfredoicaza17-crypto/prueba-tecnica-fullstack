/// Implementación consumida por la aplicación del contrato definido en la raíz.
List<String> topTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return const [];

  final frequencies = <String, int>{};
  for (final tag in tags) {
    final normalized = tag.toLowerCase();
    frequencies[normalized] = (frequencies[normalized] ?? 0) + 1;
  }

  final ordered = frequencies.entries.toList()
    ..sort((a, b) {
      final byFrequency = b.value.compareTo(a.value);
      return byFrequency != 0 ? byFrequency : a.key.compareTo(b.key);
    });
  return ordered.take(k).map((entry) => entry.key).toList(growable: false);
}
