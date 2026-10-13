import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// RF-01 · Obtiene los primeros [limit] productos del catálogo.
class GetProducts {
  const GetProducts(this._repository);

  static const defaultLimit = 20;

  final ProductRepository _repository;

  Future<Result<List<Product>>> call({int limit = defaultLimit}) =>
      _repository.getProducts(limit: limit);
}
