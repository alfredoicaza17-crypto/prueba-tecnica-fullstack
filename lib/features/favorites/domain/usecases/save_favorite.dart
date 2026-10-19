import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/favorites_repository.dart';

class SaveFavorite {
  const SaveFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<Failure?> call(Product product) => _repository.addFavorite(product);
}
