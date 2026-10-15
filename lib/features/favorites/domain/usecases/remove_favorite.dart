import '../repositories/favorite_repository.dart';

class RemoveFavorite {
  const RemoveFavorite(this._repository);

  final FavoriteRepository _repository;

  Future<void> call(int productId) => _repository.removeFavorite(productId);
}
