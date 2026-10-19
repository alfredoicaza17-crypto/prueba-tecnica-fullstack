import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remoteDataSource);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<ProductsResult> getProducts() async {
    try {
      return ProductsResult.success(await _remoteDataSource.getProducts());
    } on NetworkException {
      return const ProductsResult.failure(NetworkFailure());
    } on ServerException catch (exception) {
      return ProductsResult.failure(ServerFailure(exception.message));
    } catch (_) {
      return const ProductsResult.failure(ServerFailure());
    }
  }
}
