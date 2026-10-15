import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl(this._local, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final FavoriteLocalDataSource _local;
  final DateTime Function() _clock;

  @override
  Future<List<Favorite>> getFavorites() => _run(_local.getFavorites);

  @override
  Future<bool> isFavorite(int productId) =>
      _run(() => _local.isFavorite(productId));

  @override
  Future<void> addFavorite(Product product) =>
      _run(() => _local.insert(product, _clock()));

  @override
  Future<void> removeFavorite(int productId) =>
      _run(() => _local.delete(productId));

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on StorageException {
      throw const StorageFailure();
    }
  }
}
