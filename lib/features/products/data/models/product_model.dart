import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.tags,
    required super.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      thumbnail: (json['thumbnail'] as String?) ?? '',
    );
  }
}
