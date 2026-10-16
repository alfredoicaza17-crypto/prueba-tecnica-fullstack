class Favorite {
  const Favorite({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
    required this.addedAt,
    required this.tags,
  });

  final int id;
  final String title;
  final double price;
  final String thumbnailUrl;
  final DateTime addedAt;
  final List<String> tags;

  factory Favorite.fromDatabase(
    Map<String, Object?> row, {
    required List<String> tags,
  }) {
    return Favorite(
      id: row['id'] as int,
      title: row['title'] as String,
      price: (row['price'] as num).toDouble(),
      thumbnailUrl: row['thumbnail_url'] as String,
      addedAt: DateTime.fromMillisecondsSinceEpoch(
        row['added_at'] as int,
        isUtc: true,
      ),
      tags: tags,
    );
  }
}
