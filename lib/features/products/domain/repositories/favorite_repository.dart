import '../entities/favorite_product.dart';
import '../entities/product.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteProduct>> getFavorites();

  Future<bool> isFavorite(int productId);

  Future<void> addFavorite(Product product);

  Future<void> removeFavorite(int productId);
}
