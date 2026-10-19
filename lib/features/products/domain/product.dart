class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> tags;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.tags,
  });
}

/// El dispositivo no tiene conexión.
class NetworkException implements Exception {}

/// El servidor respondió con error o con datos inválidos.
class ServerException implements Exception {}

abstract class ProductRepository {
  Future<List<Product>> getProducts({int limit = 20});
}
