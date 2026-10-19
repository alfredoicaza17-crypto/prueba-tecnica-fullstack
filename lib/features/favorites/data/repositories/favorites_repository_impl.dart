import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDataSource);
  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<Failure?> addFavorite(Product product) async {
    try {
      await _localDataSource.addFavorite(product, DateTime.now());
      return null;
    } catch (_) {
      return const CacheFailure();
    }
  }

  @override
  Future<FavoritesResult> getFavorites() async {
    try {
      return FavoritesResult.success(await _localDataSource.getFavorites());
    } catch (_) {
      return const FavoritesResult.failure(CacheFailure());
    }
  }

  @override
  Future<Failure?> removeFavorite(int productId) async {
    try {
      await _localDataSource.removeFavorite(productId);
      return null;
    } catch (_) {
      return const CacheFailure();
    }
  }
}
