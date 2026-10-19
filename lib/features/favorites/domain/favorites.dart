import '../../products/domain/product.dart';

class Favorite {
  final Product product;
  final DateTime addedAt;

  const Favorite(this.product, this.addedAt);
}

abstract class FavoritesRepository {
  /// Del más reciente al más antiguo.
  Future<List<Favorite>> getAll();
  Future<void> add(Product product);
  Future<void> remove(int id);
}
