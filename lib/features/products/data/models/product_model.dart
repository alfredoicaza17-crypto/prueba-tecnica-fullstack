import '../../domain/entities/product.dart';

/// DTO de DummyJSON. Solo mapea los campos que usa la app.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnail,
    required super.tags,
  });

  /// Lanza [FormatException] si falta un campo obligatorio o tiene otro tipo.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        thumbnail: json['thumbnail'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
      );
    } on TypeError catch (e) {
      throw FormatException('Producto inválido: $e');
    }
  }
}
