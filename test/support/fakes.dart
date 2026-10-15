import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';
import 'package:tienda_app/features/products/domain/repositories/product_repository.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.handler);

  Future<List<Product>> Function() handler;
  int calls = 0;

  @override
  Future<List<Product>> getProducts() {
    calls++;
    return handler();
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository({DateTime? start})
      : _clock = start ?? DateTime(2026, 1, 1);

  final List<Favorite> _items = [];
  DateTime _clock;

  @override
  Future<List<Favorite>> getFavorites() async {
    final sorted = [..._items]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted;
  }

  @override
  Future<bool> isFavorite(int productId) async =>
      _items.any((favorite) => favorite.id == productId);

  @override
  Future<void> addFavorite(Product product) async {
    _clock = _clock.add(const Duration(minutes: 1));
    _items.add(
      Favorite(
        id: product.id,
        title: product.title,
        price: product.price,
        thumbnail: product.thumbnail,
        tags: product.tags,
        addedAt: _clock,
      ),
    );
  }

  @override
  Future<void> removeFavorite(int productId) async {
    _items.removeWhere((favorite) => favorite.id == productId);
  }
}
