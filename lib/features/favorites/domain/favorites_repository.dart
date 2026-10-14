import '../../catalog/domain/product.dart';
import 'favorite.dart';

abstract interface class FavoritesRepository {
  Future<List<Favorite>> getFavorites();
  Future<void> add(Product product, DateTime addedAt);
  Future<void> remove(int productId);
}
