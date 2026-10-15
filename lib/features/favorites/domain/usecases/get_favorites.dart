import '../entities/favorite.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoriteRepository _repository;

  Future<List<Favorite>> call() => _repository.getFavorites();
}
