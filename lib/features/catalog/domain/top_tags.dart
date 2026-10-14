/// Counts case-insensitively; sorts by frequency then alphabetical order.
/// O(n + u log u) time and O(u) space, with u distinct tags.
List<String> topTags(List<String> tags, int k) {
  if (k <= 0) return [];
  final counts = <String, int>{};
  for (final tag in tags) {
    final normalized = tag.toLowerCase();
    counts.update(normalized, (count) => count + 1, ifAbsent: () => 1);
  }
  final sorted = counts.keys.toList()
    ..sort((a, b) {
      final frequency = counts[b]!.compareTo(counts[a]!);
      return frequency != 0 ? frequency : a.compareTo(b);
    });
  return sorted.take(k).toList();
}
