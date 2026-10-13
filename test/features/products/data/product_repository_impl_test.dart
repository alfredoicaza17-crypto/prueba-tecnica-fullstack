import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/exceptions.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/core/error/result.dart';
import 'package:tienda_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:tienda_app/features/products/data/models/product_model.dart';
import 'package:tienda_app/features/products/data/repositories/product_repository_impl.dart';

class _MockRemote extends Mock implements ProductRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = ProductRepositoryImpl(remote);
  });

  test('retorna Ok con los productos', () async {
    const model = ProductModel(
      id: 1,
      title: 't',
      price: 1,
      thumbnail: '',
      tags: [],
    );
    when(() => remote.getProducts(limit: 20)).thenAnswer((_) async => [model]);

    final result = await repository.getProducts(limit: 20);

    expect(result, isA<Ok<dynamic>>());
    expect((result as Ok).value, [model]);
  });

  test('NetworkException → NetworkFailure', () async {
    when(
      () => remote.getProducts(limit: 20),
    ).thenThrow(const NetworkException());

    final result = await repository.getProducts(limit: 20);

    expect((result as Err).failure, isA<NetworkFailure>());
  });

  test('ServerException → ServerFailure', () async {
    when(
      () => remote.getProducts(limit: 20),
    ).thenThrow(const ServerException(statusCode: 503));

    final result = await repository.getProducts(limit: 20);

    expect((result as Err).failure, isA<ServerFailure>());
  });
}
