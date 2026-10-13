import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../models/favorite_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Result<List<Favorite>>> getFavorites() =>
      _guard(() => _local.getAll());

  @override
  Future<Result<void>> add(Favorite favorite) =>
      _guard(() => _local.upsert(FavoriteModel.fromEntity(favorite)));

  @override
  Future<Result<void>> remove(int id) => _guard(() => _local.delete(id));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on CacheException {
      return const Err(CacheFailure());
    }
  }
}
