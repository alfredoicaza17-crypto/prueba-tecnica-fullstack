/// Returns the [k] most frequent tags in lowercase.
///
/// Counting is case-insensitive. Tags are ordered by descending frequency,
/// then alphabetically. Returns an empty list when [k] is not positive, and
/// never modifies [tags].
List<String> topTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return const [];

  final frequencies = <String, int>{};
  for (final tag in tags) {
    final normalizedTag = tag.toLowerCase();
    frequencies.update(
      normalizedTag,
      (frequency) => frequency + 1,
      ifAbsent: () => 1,
    );
  }

  final rankedTags = frequencies.keys.toList()
    ..sort((left, right) {
      final frequencyOrder = frequencies[right]!.compareTo(frequencies[left]!);
      return frequencyOrder != 0 ? frequencyOrder : left.compareTo(right);
    });

  return rankedTags.take(k).toList(growable: false);
}
