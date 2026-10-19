import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnailUrl,
    required super.tags,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Sin título',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnailUrl: json['thumbnail'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}
