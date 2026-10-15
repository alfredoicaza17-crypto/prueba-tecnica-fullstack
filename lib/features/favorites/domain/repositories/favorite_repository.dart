import '../../../products/domain/entities/product.dart';
import '../entities/favorite.dart';

abstract interface class FavoriteRepository {
  Future<List<Favorite>> getFavorites();

  Future<bool> isFavorite(int productId);

  Future<void> addFavorite(Product product);

  Future<void> removeFavorite(int productId);
}
