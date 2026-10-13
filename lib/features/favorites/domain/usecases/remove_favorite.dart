import '../../../../core/error/result.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  const RemoveFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<Result<void>> call(int id) => _repository.remove(id);
}
