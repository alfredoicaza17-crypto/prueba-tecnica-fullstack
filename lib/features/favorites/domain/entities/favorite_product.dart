import '../../../products/domain/entities/product.dart';

class FavoriteProduct extends Product {
  const FavoriteProduct({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnailUrl,
    required super.tags,
    required this.addedAt,
  });

  final DateTime addedAt;
}
