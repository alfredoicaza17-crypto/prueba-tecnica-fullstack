import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/exceptions.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/favorites/data/datasources/favorite_local_datasource.dart';
import 'package:tienda_app/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';

import '../../../support/fixtures.dart';

class MockLocal extends Mock implements FavoriteLocalDataSource {}

void main() {
  late MockLocal local;
  final fixedNow = DateTime(2026, 4, 20, 10, 30);
  late FavoriteRepositoryImpl repository;

  setUp(() {
    local = MockLocal();
    repository = FavoriteRepositoryImpl(local, clock: () => fixedNow);
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(mascara);
  });

  test('addFavorite guarda con la fecha actual del reloj', () async {
    when(() => local.insert(any(), any())).thenAnswer((_) async {});

    await repository.addFavorite(mascara);

    verify(() => local.insert(mascara, fixedNow)).called(1);
  });

  test('removeFavorite elimina por id', () async {
    when(() => local.delete(any())).thenAnswer((_) async {});

    await repository.removeFavorite(1);

    verify(() => local.delete(1)).called(1);
  });

  test('getFavorites retorna lo que entrega el datasource', () async {
    final favorites = [
      Favorite(
        id: 1,
        title: 'a',
        price: 1,
        thumbnail: 't',
        tags: const ['x'],
        addedAt: fixedNow,
      ),
    ];
    when(() => local.getFavorites()).thenAnswer((_) async => favorites);

    expect(await repository.getFavorites(), favorites);
  });

  test('isFavorite delega en el datasource', () async {
    when(() => local.isFavorite(1)).thenAnswer((_) async => true);

    expect(await repository.isFavorite(1), isTrue);
  });

  test('convierte StorageException en StorageFailure', () async {
    when(() => local.getFavorites()).thenThrow(const StorageException());

    await expectLater(
      repository.getFavorites(),
      throwsA(isA<StorageFailure>()),
    );
  });
}
