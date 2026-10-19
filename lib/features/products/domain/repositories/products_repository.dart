import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract interface class ProductsRepository {
  Future<ProductsResult> getProducts();
}

class ProductsResult {
  const ProductsResult.success(this.products) : failure = null;
  const ProductsResult.failure(this.failure) : products = null;

  final List<Product>? products;
  final Failure? failure;

  bool get isSuccess => products != null;
}
