import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tienda_app/features/favorites/data/models/favorite.dart';
import 'package:tienda_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:tienda_app/features/products/data/models/product_dto.dart';
import 'package:tienda_app/features/products/data/services/product_service.dart';
import 'package:tienda_app/main.dart';

const _productResponse = '''
{
  "products": [
    {
      "id": 1,
      "title": "Essence Mascara",
      "description": "A mascara",
      "category": "beauty",
      "price": 9.99,
      "discountPercentage": 7.17,
      "rating": 4.5,
      "stock": 5,
      "thumbnail": "https://example.com/product.jpg",
      "images": [],
      "tags": ["Beauty", "mascara", "beauty"]
    },
    {
      "id": 2,
      "title": "Wooden Chair",
      "description": "A chair",
      "category": "furniture",
      "price": 49.99,
      "discountPercentage": 0,
      "rating": 4.2,
      "stock": 12,
      "thumbnail": "https://example.com/chair.jpg",
      "images": [],
      "tags": ["furniture"]
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 20
}
''';

void main() {
  testWidgets('shows products returned by fetchProducts', (tester) async {
    final service = ProductService(
      client: MockClient((request) async {
        expect(request.url.queryParameters, {'limit': '20', 'skip': '0'});
        return http.Response(_productResponse, 200);
      }),
    );

    await tester.pumpWidget(
      MyApp(
        productService: service,
        favoritesRepository: _FakeFavoritesRepository(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Ismael Moron - Tienda App'), findsOneWidget);
    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('Wooden Chair'), findsOneWidget);
    expect(find.text('beauty'), findsNWidgets(2));
    expect(find.text('\$9.99'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('filters products by popular tag and toggles the filter off', (
    tester,
  ) async {
    final service = ProductService(
      client: MockClient(
        (request) async => http.Response(_productResponse, 200),
      ),
    );

    await tester.pumpWidget(
      MyApp(
        productService: service,
        favoritesRepository: _FakeFavoritesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNWidgets(3));

    await tester.tap(find.widgetWithText(ChoiceChip, 'beauty'));
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('Wooden Chair'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'beauty'));
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('Wooden Chair'), findsOneWidget);
  });

  testWidgets('shows an error and retries fetching products', (tester) async {
    var requestCount = 0;
    final service = ProductService(
      client: MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response('Unavailable', 503);
        }
        return http.Response(_productResponse, 200);
      }),
    );

    await tester.pumpWidget(
      MyApp(
        productService: service,
        favoritesRepository: _FakeFavoritesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Error al cargar los datos (código 503).'),
      findsOneWidget,
    );
    expect(find.text('Inténtalo de nuevo más tarde.'), findsOneWidget);
    expect(find.textContaining('Request to'), findsNothing);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(requestCount, 2);
    expect(find.text('Essence Mascara'), findsOneWidget);
  });

  testWidgets('shows an offline message for connection errors', (tester) async {
    final service = ProductService(
      client: MockClient((request) async {
        throw http.ClientException('Failed host lookup');
      }),
    );

    await tester.pumpWidget(
      MyApp(
        productService: service,
        favoritesRepository: _FakeFavoritesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(
      find.text('Comprueba tu conexión e inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.textContaining('código'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('navigates between product pages', (tester) async {
    var requestCount = 0;
    final service = ProductService(
      client: MockClient((request) async {
        final expectedSkip = ['0', '20', '0'][requestCount];
        expect(request.url.queryParameters, {
          'limit': '20',
          'skip': expectedSkip,
        });
        requestCount++;
        return http.Response(
          _productResponse.replaceFirst('"total": 2', '"total": 41'),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MyApp(
        productService: service,
        favoritesRepository: _FakeFavoritesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Página 1 de 3'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.chevron_left),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Página 2 de 3'), findsOneWidget);
    expect(requestCount, 2);

    await tester.tap(find.byTooltip('Página anterior'));
    await tester.pumpAndSettle();

    expect(find.text('Página 1 de 3'), findsOneWidget);
    expect(requestCount, 3);
  });

  testWidgets('marks a product as favorite and then removes it', (
    tester,
  ) async {
    final repository = _FakeFavoritesRepository();
    final service = ProductService(
      client: MockClient(
        (request) async => http.Response(_productResponse, 200),
      ),
    );

    await tester.pumpWidget(
      MyApp(productService: service, favoritesRepository: repository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar a favoritos').first);
    await tester.pumpAndSettle();

    expect(repository.favorites, contains(1));
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pumpAndSettle();

    expect(repository.favorites, isEmpty);
    expect(find.byTooltip('Agregar a favoritos'), findsNWidgets(2));
  });
}

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository() : super(databaseProvider: _unusedDatabaseProvider);

  static Future<Database> _unusedDatabaseProvider() =>
      throw UnimplementedError('The widget tests use the in-memory fake.');

  final Set<int> favorites = {};

  @override
  Future<List<Favorite>> getFavorites() async => const [];

  @override
  Future<Set<int>> getFavoriteIds() async => favorites.toSet();

  @override
  Future<void> addFavorite(ProductDto product) async {
    favorites.add(product.id);
  }

  @override
  Future<void> removeFavorite(int productId) async {
    favorites.remove(productId);
  }
}
