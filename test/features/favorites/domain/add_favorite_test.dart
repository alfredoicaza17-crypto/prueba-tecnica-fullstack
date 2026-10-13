import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/core/error/result.dart';
import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/usecases/add_favorite.dart';

class _MockRepo extends Mock implements FavoritesRepository {}

void main() {
  final now = DateTime.utc(2026, 10, 13, 9);
  late _MockRepo repo;

  setUpAll(
    () => registerFallbackValue(
      Favorite(
        id: 0,
        title: '',
        price: 0,
        thumbnail: '',
        tags: const [],
        addedAt: DateTime(2000),
      ),
    ),
  );

  setUp(() => repo = _MockRepo());

  test('guarda el favorito con la fecha actual', () async {
    when(() => repo.add(any())).thenAnswer((_) async => const Ok(null));

    final result = await AddFavorite(repo, now: () => now)(
      id: 1,
      title: 'Mascara',
      price: 9.99,
      thumbnail: 'url',
      tags: const ['beauty'],
    );

    final saved =
        verify(() => repo.add(captureAny())).captured.single as Favorite;
    expect(saved.addedAt, now);
    expect(saved.tags, ['beauty']);
    expect((result as Ok<Favorite>).value, saved);
  });

  test('propaga el failure del repositorio', () async {
    when(
      () => repo.add(any()),
    ).thenAnswer((_) async => const Err(CacheFailure()));

    final result = await AddFavorite(repo, now: () => now)(
      id: 1,
      title: 'x',
      price: 1,
      thumbnail: '',
      tags: const [],
    );

    expect((result as Err).failure, const CacheFailure());
  });
}
