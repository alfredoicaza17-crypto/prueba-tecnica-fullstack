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
  "limit": 30
}
''';

void main() {
  testWidgets('shows products returned by fetchProducts', (tester) async {
    final service = ProductService(
      client: MockClient((request) async {
        expect(request.url.queryParameters, {'limit': '30', 'skip': '0'});
        return http.Response(_productResponse, 200);
      }),
    );

    await tester.pumpWidget(MyApp(productService: service));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Productos'), findsOneWidget);
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

    expect(find.text('No se pudieron cargar los productos.'), findsOneWidget);
    expect(find.textContaining('503'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(requestCount, 2);
    expect(find.text('Essence Mascara'), findsOneWidget);
  });
}
