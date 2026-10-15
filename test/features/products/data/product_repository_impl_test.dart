import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/exceptions.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:tienda_app/features/products/data/models/product_model.dart';
import 'package:tienda_app/features/products/data/repositories/product_repository_impl.dart';

class MockRemote extends Mock implements ProductRemoteDataSource {}

void main() {
  late MockRemote remote;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = MockRemote();
    repository = ProductRepositoryImpl(remote);
  });

  group('ProductRepositoryImpl.getProducts', () {
    test('retorna los productos del datasource', () async {
      const model = ProductModel(
        id: 1,
        title: 'a',
        price: 1,
        tags: ['x'],
        thumbnail: 't',
      );
      when(() => remote.fetchProducts()).thenAnswer((_) async => [model]);

      final products = await repository.getProducts();

      expect(products, [model]);
    });

    test('convierte NetworkException en NetworkFailure', () async {
      when(() => remote.fetchProducts()).thenThrow(const NetworkException());

      await expectLater(
        repository.getProducts(),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('convierte ServerException en ServerFailure', () async {
      when(() => remote.fetchProducts()).thenThrow(const ServerException(500));

      await expectLater(
        repository.getProducts(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
