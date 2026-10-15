import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tienda_app/core/error/exceptions.dart';
import 'package:tienda_app/features/products/data/datasources/product_remote_datasource.dart';

import '../../../support/fixtures.dart';

ProductRemoteDataSourceImpl buildDataSource(
  Future<http.Response> Function(http.Request) handler, {
  Duration timeout = const Duration(seconds: 5),
}) {
  return ProductRemoteDataSourceImpl(MockClient(handler), timeout: timeout);
}

void main() {
  group('ProductRemoteDataSourceImpl', () {
    test('consulta products con limit=20 en DummyJSON', () async {
      late http.Request captured;
      final dataSource = buildDataSource((request) async {
        captured = request;
        return http.Response(productsJson, 200);
      });

      await dataSource.fetchProducts();

      expect(captured.method, 'GET');
      expect(captured.url.host, 'dummyjson.com');
      expect(captured.url.path, '/products');
      expect(captured.url.queryParameters['limit'], '20');
    });

    test('agrega delay=2000 para simular una red lenta', () async {
      late http.Request captured;
      final dataSource = buildDataSource((request) async {
        captured = request;
        return http.Response(productsJson, 200);
      });

      await dataSource.fetchProducts();

      expect(captured.url.queryParameters['delay'], '2000');
    });

    test('el timeout por defecto tolera el retraso de 2 segundos', () {
      final dataSource = ProductRemoteDataSourceImpl(
        MockClient((_) async => http.Response(productsJson, 200)),
      );

      expect(
        dataSource.timeout,
        greaterThan(const Duration(milliseconds: 2000)),
      );
    });

    test('parsea la lista de productos', () async {
      final dataSource = buildDataSource(
        (_) async => http.Response(productsJson, 200),
      );

      final products = await dataSource.fetchProducts();

      expect(products.length, 2);
      expect(products.first.title, 'Essence Mascara Lash Princess');
      expect(products.last.price, 20.0);
    });

    test('decodifica UTF-8 correctamente', () async {
      final body = jsonEncode({
        'products': [
          {
            'id': 9,
            'title': 'Crema hidratante ñandú',
            'price': 5,
            'tags': ['piel'],
            'thumbnail': 't',
          },
        ],
      });
      final dataSource = buildDataSource(
        (_) async => http.Response.bytes(utf8.encode(body), 200),
      );

      final products = await dataSource.fetchProducts();

      expect(products.single.title, 'Crema hidratante ñandú');
    });

    test('devuelve lista vacia si la API no trae productos', () async {
      final dataSource = buildDataSource(
        (_) async => http.Response('{"products": []}', 200),
      );

      expect(await dataSource.fetchProducts(), isEmpty);
    });

    test('lanza ServerException con el codigo si responde 500', () async {
      final dataSource = buildDataSource((_) async => http.Response('', 500));

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'status', 500),
        ),
      );
    });

    test('lanza ServerException si responde 404', () async {
      final dataSource = buildDataSource((_) async => http.Response('', 404));

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza ServerException si el cuerpo no es JSON', () async {
      final dataSource = buildDataSource(
        (_) async => http.Response('no es json', 200),
      );

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza ServerException si el JSON no trae products', () async {
      final dataSource = buildDataSource(
        (_) async => http.Response('{"total": 0}', 200),
      );

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza NetworkException ante SocketException', () async {
      final dataSource = buildDataSource(
        (_) async => throw const SocketException('sin red'),
      );

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('lanza NetworkException ante ClientException', () async {
      final dataSource = buildDataSource(
        (_) async => throw http.ClientException('fallo'),
      );

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('lanza NetworkException si se agota el tiempo de espera', () async {
      final dataSource = buildDataSource(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response(productsJson, 200);
        },
        timeout: const Duration(milliseconds: 20),
      );

      await expectLater(
        dataSource.fetchProducts(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
