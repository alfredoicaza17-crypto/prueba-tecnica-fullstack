import '../../catalog/domain/product.dart';
import 'favorite.dart';
import 'favorites_repository.dart';

class ManageFavorites {
  final FavoritesRepository repository;
  final DateTime Function() clock;
  ManageFavorites(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  Future<List<Favorite>> load() => repository.getFavorites();
  Future<void> add(Product product) => repository.add(product, clock().toUtc());
  Future<void> remove(int id) => repository.remove(id);
}
