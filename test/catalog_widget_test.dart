import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/app.dart';
import 'package:tienda_app/core/presentation/catalog_skeleton.dart';
import 'package:tienda_app/features/catalog/domain/get_products.dart';
import 'package:tienda_app/features/catalog/domain/product.dart';
import 'package:tienda_app/features/catalog/domain/product_repository.dart';
import 'package:tienda_app/features/catalog/presentation/catalog_controller.dart';
import 'package:tienda_app/features/favorites/domain/favorite.dart';
import 'package:tienda_app/features/favorites/domain/favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/manage_favorites.dart';
import 'package:tienda_app/features/favorites/presentation/favorites_controller.dart';

class FakeProducts implements ProductRepository {
  Future<List<Product>> Function() handler;
  FakeProducts(this.handler);
  @override
  Future<List<Product>> getProducts() => handler();
}

class MemoryFavorites implements FavoritesRepository {
  final items = <Favorite>[];
  bool failWrite = false;
  @override
  Future<List<Favorite>> getFavorites() async => List.of(items);
  @override
  Future<void> add(Product product, DateTime addedAt) async {
    if (failWrite) throw StateError('disk full');
    items.insert(0, Favorite(product: product, addedAt: addedAt));
  }

  @override
  Future<void> remove(int productId) async {
    if (failWrite) throw StateError('disk full');
    items.removeWhere((f) => f.product.id == productId);
  }
}

void main() {
  late FakeProducts repository;
  late CatalogController catalog;
  late FavoritesController favorites;
  late MemoryFavorites store;
  final products = [
    Product(
      id: 1,
      title: 'Mascara',
      price: 9.99,
      thumbnail: 'https://example.com/1',
      tags: ['Beauty'],
    ),
    Product(
      id: 2,
      title: 'Carne',
      price: 5,
      thumbnail: 'https://example.com/2',
      tags: ['meat'],
    ),
  ];
  setUp(() {
    repository = FakeProducts(() async => products);
    catalog = CatalogController(GetProducts(repository));
    store = MemoryFavorites();
    favorites = FavoritesController(ManageFavorites(store));
  });
  tearDown(() {
    catalog.dispose();
    favorites.dispose();
  });
  Future<void> render(WidgetTester tester) async {
    await favorites.load();
    await tester.pumpWidget(TiendaApp(catalog: catalog, favorites: favorites));
  }

  testWidgets('loading, products, tags and filter toggle', (tester) async {
    final gate = Completer<List<Product>>();
    repository.handler = () => gate.future;
    await render(tester);
    final load = catalog.load();
    await tester.pump();
    expect(find.byType(CatalogSkeleton), findsOneWidget);
    expect(catalog.popularTags, isEmpty);
    gate.complete(products);
    await load;
    await tester.pumpAndSettle();
    expect(find.text('Mascara'), findsOneWidget);
    expect(find.text('USD 9.99'), findsOneWidget);
    await tester.tap(find.text('Beauty'));
    await tester.pumpAndSettle();
    expect(find.text('Carne'), findsNothing);
    expect(catalog.selectedTag, 'beauty');
    await tester.tap(find.text('Beauty'));
    await tester.pumpAndSettle();
    expect(find.text('Carne'), findsOneWidget);
  });
  testWidgets('server error can retry and show empty state', (tester) async {
    repository.handler = () async =>
        throw const CatalogException(CatalogFailure.server);
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(find.textContaining('servidor'), findsOneWidget);
    repository.handler = () async => [];
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay productos disponibles.'), findsOneWidget);
  });
  testWidgets('offline favorites, navigation, removal and empty state', (
    tester,
  ) async {
    await store.add(products.first, DateTime.utc(2026));
    repository.handler = () async =>
        throw const CatalogException(CatalogFailure.offline);
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin conexión'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Mascara'), findsOneWidget);
    expect(find.text('Beauty'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no tienes favoritos'), findsOneWidget);
  });
  testWidgets('favorite add and failed removal keep UI consistent', (
    tester,
  ) async {
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    store.failWrite = true;
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    expect(find.textContaining('No se pudo actualizar'), findsOneWidget);
  });
  testWidgets('small screen and enlarged text remain usable', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await store.add(products.first, DateTime.utc(2026));
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Beauty'), findsOneWidget);
  });
  testWidgets('skeleton respects reduced motion on small screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(320, 700), disableAnimations: true),
          child: SizedBox(width: 320, height: 700, child: CatalogSkeleton()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CatalogSkeleton), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(430, 932),
    const Size(844, 390),
    const Size(600, 960),
    const Size(800, 1280),
    const Size(1024, 768),
    const Size(1366, 1024),
  ]) {
    testWidgets('responsive catalog and favorites at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final longProduct = Product(
        id: 10,
        title:
            'Producto con un título especialmente largo para verificar la adaptación de la tarjeta',
        price: 1899.99,
        thumbnail: 'https://example.com/10',
        tags: ['fragrances', 'perfumes', 'beauty', 'Una etiqueta extensa'],
      );
      repository.handler = () async => [longProduct, ...products];
      await store.add(longProduct, DateTime.utc(2026));
      await render(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await catalog.load();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('favorite-10')), findsOneWidget);
      await tester.tap(find.byTooltip('Favoritos'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(longProduct.title), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      for (final failure in [CatalogFailure.server, CatalogFailure.offline]) {
        repository.handler = () async => throw CatalogException(failure);
        await catalog.load();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Reintentar'), findsOneWidget);
      }
      repository.handler = () async => [];
      await catalog.load();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('No hay productos disponibles.'), findsOneWidget);
    });
  }
}
