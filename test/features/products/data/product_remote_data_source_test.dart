import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tienda_app/core/error/exceptions.dart';
import 'package:tienda_app/features/products/data/datasources/product_remote_data_source.dart';

void main() {
  const body = {
    'products': [
      {
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'price': 9.99,
        'tags': ['beauty', 'mascara'],
        'thumbnail': 'https://cdn.dummyjson.com/x.webp',
      },
      {
        'id': 2,
        'title': 'Sin etiquetas',
        'price': 5,
        'thumbnail': 'https://cdn.dummyjson.com/y.webp',
      },
    ],
    'total': 194,
    'skip': 0,
    'limit': 20,
  };

  ProductRemoteDataSourceImpl sourceWith(MockClientHandler handler) =>
      ProductRemoteDataSourceImpl(client: MockClient(handler));

  test('pide /products?limit=N y parsea la respuesta', () async {
    late Uri requested;
    final source = sourceWith((req) async {
      requested = req.url;
      return http.Response(jsonEncode(body), 200);
    });

    final products = await source.getProducts(limit: 20);

    expect(requested.toString(), 'https://dummyjson.com/products?limit=20');
    expect(products, hasLength(2));
    expect(products.first.title, 'Essence Mascara Lash Princess');
    expect(products.first.tags, ['beauty', 'mascara']);
    expect(products[1].price, 5.0);
    expect(products[1].tags, isEmpty);
  });

  test('status distinto de 200 lanza ServerException', () {
    final source = sourceWith((_) async => http.Response('boom', 500));
    expect(
      source.getProducts(limit: 20),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500),
      ),
    );
  });

  test('JSON inválido lanza ServerException', () {
    final source = sourceWith((_) async => http.Response('<html>', 200));
    expect(source.getProducts(limit: 20), throwsA(isA<ServerException>()));
  });

  test('producto con tipos inesperados lanza ServerException', () {
    final source = sourceWith(
      (_) async => http.Response(
        jsonEncode({
          'products': [
            {'id': '1', 'title': 'x', 'price': 1},
          ],
        }),
        200,
      ),
    );
    expect(source.getProducts(limit: 20), throwsA(isA<ServerException>()));
  });

  test('SocketException lanza NetworkException', () {
    final source = sourceWith(
      (_) async => throw const SocketException('Failed host lookup'),
    );
    expect(source.getProducts(limit: 20), throwsA(isA<NetworkException>()));
  });

  test('ClientException lanza NetworkException', () {
    final source = sourceWith(
      (_) async => throw http.ClientException('Connection refused'),
    );
    expect(source.getProducts(limit: 20), throwsA(isA<NetworkException>()));
  });

  test('timeout lanza NetworkException', () {
    final source = ProductRemoteDataSourceImpl(
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response(jsonEncode(body), 200);
      }),
      timeout: const Duration(milliseconds: 10),
    );
    expect(source.getProducts(limit: 20), throwsA(isA<NetworkException>()));
  });
}
