import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<List<Product>> getProducts() async {
    try {
      return await _remote.fetchProducts();
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException {
      throw const ServerFailure();
    }
  }
}
