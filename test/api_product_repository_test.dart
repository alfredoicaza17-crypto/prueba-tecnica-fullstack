import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tienda_app/features/catalog/data/api_product_repository.dart';
import 'package:tienda_app/features/catalog/domain/product_repository.dart';

void main() {
  final row = {
    'id': 1,
    'title': 'Producto',
    'price': 9,
    'thumbnail': 'https://example.com/p.webp',
    'tags': ['Beauty'],
  };
  test('requests the first twenty and parses product fields', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://dummyjson.com/products?limit=20');
      return http.Response(
        jsonEncode({
          'products': [row],
        }),
        200,
      );
    });
    final products = await ApiProductRepository(client).getProducts();
    expect(products.single.price, 9.0);
    expect(products.single.tags, ['Beauty']);
    expect(products.single.id, 1);
    expect(products.single.title, 'Producto');
    expect(products.single.thumbnail, 'https://example.com/p.webp');
  });
  test('empty response', () async {
    expect(
      await ApiProductRepository(
        MockClient((_) async => http.Response('{"products":[]}', 200)),
      ).getProducts(),
      isEmpty,
    );
  });
  for (final status in [400, 500, 503]) {
    test('HTTP $status is a server failure', () async {
      await expectLater(
        ApiProductRepository(
          MockClient((_) async => http.Response('{}', status)),
        ).getProducts(),
        throwsA(
          isA<CatalogException>().having(
            (e) => e.failure,
            'failure',
            CatalogFailure.server,
          ),
        ),
      );
    });
  }
  test('transport failure differs from server failure', () async {
    await expectLater(
      ApiProductRepository(
        MockClient((_) async => throw http.ClientException('offline')),
      ).getProducts(),
      throwsA(
        isA<CatalogException>().having(
          (e) => e.failure,
          'failure',
          CatalogFailure.offline,
        ),
      ),
    );
  });
  test('timeout returns a connection failure', () async {
    await expectLater(
      ApiProductRepository(
        MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 5),
      ).getProducts(),
      throwsA(
        isA<CatalogException>().having(
          (e) => e.failure,
          'failure',
          CatalogFailure.offline,
        ),
      ),
    );
  });
  for (final body in ['not-json', '{}', '{"products":[{"id":"wrong"}]}']) {
    test('malformed response: $body', () async {
      await expectLater(
        ApiProductRepository(
          MockClient((_) async => http.Response(body, 200)),
        ).getProducts(),
        throwsA(
          isA<CatalogException>().having(
            (e) => e.failure,
            'failure',
            CatalogFailure.invalidResponse,
          ),
        ),
      );
    });
  }
}
