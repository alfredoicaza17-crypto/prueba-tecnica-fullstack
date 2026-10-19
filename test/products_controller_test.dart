import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/favorites/domain/favorites.dart';
import 'package:tienda_app/features/products/domain/product.dart';
import 'package:tienda_app/features/products/presentation/products_controller.dart';

class FakeProducts implements ProductRepository {
  Object? error;
  List<Product> data = [];

  @override
  Future<List<Product>> getProducts({int limit = 20}) async {
    if (error != null) throw error!;
    return data;
  }
}

class FakeFavorites implements FavoritesRepository {
  final items = <Favorite>[];

  @override
  Future<List<Favorite>> getAll() async => items;

  @override
  Future<void> add(Product product) async =>
      items.insert(0, Favorite(product, DateTime.now()));

  @override
  Future<void> remove(int id) async =>
      items.removeWhere((f) => f.product.id == id);
}

Product product(int id, List<String> tags) => Product(
      id: id,
      title: 'P$id',
      price: 1,
      thumbnail: '',
      tags: tags,
    );

void main() {
  late FakeProducts products;
  late FakeFavorites favorites;
  late ProductsController controller;

  setUp(() {
    products = FakeProducts();
    favorites = FakeFavorites();
    controller = ProductsController(products, favorites);
  });

  test('carga productos', () async {
    products.data = [product(1, ['a'])];
    await controller.load();
    expect(controller.status, ProductsStatus.loaded);
    expect(controller.products.length, 1);
  });

  test('distingue sin conexión de error del servidor', () async {
    products.error = NetworkException();
    await controller.load();
    expect(controller.status, ProductsStatus.offline);

    products.error = ServerException();
    await controller.load();
    expect(controller.status, ProductsStatus.error);
  });

  test('lista vacía queda en loaded sin productos', () async {
    await controller.load();
    expect(controller.status, ProductsStatus.loaded);
    expect(controller.products, isEmpty);
  });

  test('filtra por etiqueta y la quita al tocarla de nuevo', () async {
    products.data = [product(1, ['a']), product(2, ['b'])];
    await controller.load();

    controller.toggleTag('a');
    expect(controller.products.map((p) => p.id), [1]);

    controller.toggleTag('a');
    expect(controller.products.length, 2);
  });

  test('marca y desmarca favoritos', () async {
    final p = product(1, ['a']);
    products.data = [p];
    await controller.load();

    await controller.toggleFavorite(p);
    expect(controller.favoriteIds, {1});
    expect(favorites.items.length, 1);

    await controller.toggleFavorite(p);
    expect(controller.favoriteIds, isEmpty);
    expect(favorites.items, isEmpty);
  });
}
