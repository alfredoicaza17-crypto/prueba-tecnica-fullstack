import '../repositories/favorites_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<FavoritesResult> call() => _repository.getFavorites();
}
