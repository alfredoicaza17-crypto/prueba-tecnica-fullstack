import '../../../products/domain/entities/product.dart';
import '../repositories/favorite_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoriteRepository _repository;

  Future<void> call(Product product) async {
    if (await _repository.isFavorite(product.id)) {
      await _repository.removeFavorite(product.id);
    } else {
      await _repository.addFavorite(product);
    }
  }
}
