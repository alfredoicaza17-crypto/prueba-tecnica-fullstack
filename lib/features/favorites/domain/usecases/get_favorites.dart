import '../../../../core/error/result.dart';
import '../entities/favorite.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<Favorite>>> call() => _repository.getFavorites();
}
