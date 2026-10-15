import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:tienda_app/features/favorites/domain/usecases/toggle_favorite.dart';

import '../../../support/fixtures.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late ToggleFavorite toggleFavorite;

  setUp(() {
    repository = MockFavoriteRepository();
    toggleFavorite = ToggleFavorite(repository);
    registerFallbackValue(mascara);
  });

  test('agrega el producto si todavia no es favorito', () async {
    when(() => repository.isFavorite(mascara.id)).thenAnswer((_) async => false);
    when(() => repository.addFavorite(any())).thenAnswer((_) async {});

    await toggleFavorite(mascara);

    verify(() => repository.addFavorite(mascara)).called(1);
    verifyNever(() => repository.removeFavorite(any()));
  });

  test('quita el producto si ya es favorito', () async {
    when(() => repository.isFavorite(mascara.id)).thenAnswer((_) async => true);
    when(() => repository.removeFavorite(any())).thenAnswer((_) async {});

    await toggleFavorite(mascara);

    verify(() => repository.removeFavorite(mascara.id)).called(1);
    verifyNever(() => repository.addFavorite(any()));
  });
}
