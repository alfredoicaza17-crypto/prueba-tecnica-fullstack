import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/save_favorite.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';
import 'package:tienda_app/features/products/domain/repositories/products_repository.dart';
import 'package:tienda_app/features/products/domain/usecases/get_products.dart';
import 'package:tienda_app/features/products/presentation/product_list_controller.dart';

void main() {
  final product1 = Product(
    id: 1,
    title: 'Labial',
    price: 10,
    thumbnailUrl: '',
    tags: const ['beauty', 'makeup'],
  );
  final product2 = Product(
    id: 2,
    title: 'Crema',
    price: 20,
    thumbnailUrl: '',
    tags: const ['beauty', 'skin'],
  );

  ProductListController controllerFor({
    required ProductsResult products,
    FavoritesResult favorites = const FavoritesResult.success([]),
  }) {
    final favoriteRepository = _FavoritesRepository(favorites);
    return ProductListController(
      GetProducts(_ProductsRepository(products)),
      GetFavorites(favoriteRepository),
      SaveFavorite(favoriteRepository),
      RemoveFavorite(favoriteRepository),
    );
  }

  test(
    'muestra estado sin conexión cuando falla la solicitud de red',
    () async {
      final controller = controllerFor(
        products: const ProductsResult.failure(NetworkFailure()),
      );

      await controller.load();

      expect(controller.status, ProductListStatus.offline);
      expect(controller.message, 'No tienes conexión a internet.');
    },
  );

  test('carga favoritos y filtra los productos por etiqueta', () async {
    final controller = controllerFor(
      products: ProductsResult.success([product1, product2]),
      favorites: FavoritesResult.success([
        FavoriteProduct(
          id: product2.id,
          title: product2.title,
          price: product2.price,
          thumbnailUrl: product2.thumbnailUrl,
          tags: product2.tags,
          addedAt: DateTime(2026),
        ),
      ]),
    );

    await controller.load();
    controller.toggleTag('skin');

    expect(controller.status, ProductListStatus.content);
    expect(controller.isFavorite(product2), isTrue);
    expect(controller.products, [product2]);
    expect(controller.tags.first, 'beauty');
  });
}

class _ProductsRepository implements ProductsRepository {
  const _ProductsRepository(this.result);
  final ProductsResult result;

  @override
  Future<ProductsResult> getProducts() async => result;
}

class _FavoritesRepository implements FavoritesRepository {
  const _FavoritesRepository(this.result);
  final FavoritesResult result;

  @override
  Future<Failure?> addFavorite(Product product) async => null;

  @override
  Future<FavoritesResult> getFavorites() async => result;

  @override
  Future<Failure?> removeFavorite(int productId) async => null;
}
