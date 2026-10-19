import '../../../../core/error/failures.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  const RemoveFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<Failure?> call(int productId) => _repository.removeFavorite(productId);
}
