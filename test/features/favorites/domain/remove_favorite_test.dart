import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';

import '../../../support/fixtures.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  setUp(() {
    registerFallbackValue(mascara);
  });

  test('quita el favorito del repositorio por su id', () async {
    final repository = MockFavoriteRepository();
    when(() => repository.removeFavorite(any())).thenAnswer((_) async {});

    await RemoveFavorite(repository)(7);

    verify(() => repository.removeFavorite(7)).called(1);
    verifyNever(() => repository.addFavorite(any()));
  });
}
