import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts();
}

enum CatalogFailure { offline, server, invalidResponse }

class CatalogException implements Exception {
  final CatalogFailure failure;
  const CatalogException(this.failure);
}
