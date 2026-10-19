import '../../../../core/error/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/favorite_product.dart';

abstract interface class FavoritesRepository {
  Future<FavoritesResult> getFavorites();
  Future<Failure?> addFavorite(Product product);
  Future<Failure?> removeFavorite(int productId);
}

class FavoritesResult {
  const FavoritesResult.success(this.favorites) : failure = null;
  const FavoritesResult.failure(this.failure) : favorites = null;

  final List<FavoriteProduct>? favorites;
  final Failure? failure;

  bool get isSuccess => favorites != null;
}
