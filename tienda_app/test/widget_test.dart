import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      "images": []
    }
  ],
  "total": 1,
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

    await tester.pumpWidget(MyApp(productService: service));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Ismael Moron - Tienda App'), findsOneWidget);
    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('beauty'), findsOneWidget);
    expect(find.text('\$9.99'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
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

    await tester.pumpWidget(MyApp(productService: service));
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

    await tester.pumpWidget(MyApp(productService: service));
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
          _productResponse.replaceFirst('"total": 1', '"total": 41'),
          200,
        );
      }),
    );

    await tester.pumpWidget(MyApp(productService: service));
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
}
