import 'product.dart';
import 'product_repository.dart';

class GetProducts {
  final ProductRepository repository;
  const GetProducts(this.repository);
  Future<List<Product>> call() => repository.getProducts();
}
