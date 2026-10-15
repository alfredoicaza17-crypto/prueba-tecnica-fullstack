import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tienda_app/features/products/data/services/product_service.dart'
    show ProductService;
import 'package:tienda_app/features/products/data/utils/product_api_utils.dart'
    show ProductServiceException;

void main() {
  const productJson = <String, dynamic>{
    'id': 1,
    'title': 'Essence Mascara Lash Princess',
    'description': 'The Essence Mascara Lash Princess is a popular mascara.',
    'category': 'beauty',
    'price': 9.99,
    'discountPercentage': 10.48,
    'rating': 2.56,
    'stock': 99,
    'thumbnail': 'https://example.com/thumbnail.webp',
    'images': ['https://example.com/product.webp'],
  };

  http.Response jsonResponse(Object body, {int statusCode = 200}) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  test('fetchProducts requests a paginated list', () async {
    late Uri requestedUri;
    final service = ProductService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return jsonResponse({
          'products': [productJson],
          'total': 194,
          'skip': 10,
          'limit': 5,
        });
      }),
    );

    final result = await service.fetchProducts(limit: 5, skip: 10);

    expect(requestedUri.path, '/products');
    expect(requestedUri.queryParameters, {'limit': '5', 'skip': '10'});
    expect(result.products.single.id, 1);
    expect(result.total, 194);
    expect(result.skip, 10);
    expect(result.limit, 5);
  });

  test('fetchProductById requests and parses one product', () async {
    late Uri requestedUri;
    final service = ProductService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return jsonResponse(productJson);
      }),
    );

    final result = await service.fetchProductById(1);

    expect(requestedUri.path, '/products/1');
    expect(result.id, 1);
    expect(result.title, 'Essence Mascara Lash Princess');
  });

  test('throws a service exception when the API returns an error', () async {
    final service = ProductService(
      client: MockClient(
        (_) async => jsonResponse({'message': 'Not found'}, statusCode: 404),
      ),
    );

    await expectLater(
      service.fetchProductById(999),
      throwsA(
        isA<ProductServiceException>().having(
          (error) => error.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });

  test('rejects invalid pagination and product identifiers', () {
    final service = ProductService(
      client: MockClient((_) async => jsonResponse({})),
    );

    expect(() => service.fetchProducts(limit: 0), throwsArgumentError);
    expect(() => service.fetchProducts(skip: -1), throwsArgumentError);
    expect(() => service.fetchProductById(0), throwsArgumentError);
  });
}
