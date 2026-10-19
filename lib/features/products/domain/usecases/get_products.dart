import '../repositories/products_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductsRepository _repository;

  Future<ProductsResult> call() => _repository.getProducts();
}
