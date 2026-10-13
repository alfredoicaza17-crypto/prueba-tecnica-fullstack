import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<List<Product>>> getProducts({required int limit}) async {
    try {
      return Ok(await _remote.getProducts(limit: limit));
    } on NetworkException {
      return const Err(NetworkFailure());
    } on ServerException {
      return const Err(ServerFailure());
    }
  }
}
