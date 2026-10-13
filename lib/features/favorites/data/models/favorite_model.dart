import '../../domain/entities/favorite.dart';

/// Mapeo entre [Favorite] y la fila de la tabla `favorites`.
/// Las etiquetas viven en `tags`/`favorite_tags` y se pasan aparte.
class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnail,
    required super.tags,
    required super.addedAt,
  });

  factory FavoriteModel.fromEntity(Favorite f) => FavoriteModel(
    id: f.id,
    title: f.title,
    price: f.price,
    thumbnail: f.thumbnail,
    tags: f.tags,
    addedAt: f.addedAt,
  );

  factory FavoriteModel.fromRow(Map<String, Object?> row, List<String> tags) =>
      FavoriteModel(
        id: row['product_id']! as int,
        title: row['title']! as String,
        price: (row['price']! as num).toDouble(),
        thumbnail: row['thumbnail_url']! as String,
        tags: tags,
        addedAt: DateTime.fromMillisecondsSinceEpoch(
          row['added_at']! as int,
          isUtc: true,
        ).toLocal(),
      );

  Map<String, Object?> toRow() => {
    'product_id': id,
    'title': title,
    'price': price,
    'thumbnail_url': thumbnail,
    'added_at': addedAt.toUtc().millisecondsSinceEpoch,
  };
}
