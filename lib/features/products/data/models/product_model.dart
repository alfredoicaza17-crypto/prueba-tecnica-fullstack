import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.tags,
    required super.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      // Aseguramos que el precio sea double por si viene como int en la API
      price: (json['price'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      thumbnail: json['thumbnail'],
    );
  }
}