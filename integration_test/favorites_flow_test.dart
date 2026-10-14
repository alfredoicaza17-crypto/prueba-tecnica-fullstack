import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:tienda_app/app.dart';
import 'package:tienda_app/features/catalog/data/api_product_repository.dart';
import 'package:tienda_app/features/catalog/domain/get_products.dart';
import 'package:tienda_app/features/catalog/presentation/catalog_controller.dart';
import 'package:tienda_app/features/favorites/data/sqlite_favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/manage_favorites.dart';
import 'package:tienda_app/features/favorites/presentation/favorites_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native SQLite persists favorites and displays them offline', (
    tester,
  ) async {
    final dbPath = path.join(
      await getDatabasesPath(),
      'integration_favorites.db',
    );
    await deleteDatabase(dbPath);
    Future<Database> open() => openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: SqliteFavoritesRepository.createSchema,
    );
    var db = await open();
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'products': [
            {
              'id': 1,
              'title': 'Producto persistente',
              'price': 9.99,
              'thumbnail': 'https://example.invalid/test.png',
              'tags': ['Beauty', 'mascara'],
            },
            {
              'id': 2,
              'title': 'Otro producto',
              'price': 5,
              'thumbnail': 'https://example.invalid/test.png',
              'tags': ['meat'],
            },
          ],
        }),
        200,
      ),
    );
    final catalog = CatalogController(
      GetProducts(ApiProductRepository(client)),
    );
    var favorites = FavoritesController(
      ManageFavorites(SqliteFavoritesRepository(db)),
    );
    await favorites.load();
    await catalog.load();
    await tester.pumpWidget(TiendaApp(catalog: catalog, favorites: favorites));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beauty'));
    await tester.pumpAndSettle();
    expect(find.text('Otro producto'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    await tester.pumpWidget(const SizedBox());
    favorites.dispose();
    catalog.dispose();
    client.close();
    await db.close();

    db = await open();
    favorites = FavoritesController(
      ManageFavorites(SqliteFavoritesRepository(db)),
    );
    final offlineClient = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    final offline = CatalogController(
      GetProducts(ApiProductRepository(offlineClient)),
    );
    await favorites.load();
    await offline.load();
    await tester.pumpWidget(TiendaApp(catalog: offline, favorites: favorites));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin conexión'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Producto persistente'), findsOneWidget);
    expect(find.text('USD 9.99'), findsOneWidget);
    expect(find.text('Beauty'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no tienes favoritos'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    favorites.dispose();
    offline.dispose();
    offlineClient.close();
    await db.close();
    await deleteDatabase(dbPath);
  });
}
