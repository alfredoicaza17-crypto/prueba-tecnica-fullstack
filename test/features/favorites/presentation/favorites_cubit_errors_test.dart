import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/core/error/result.dart';
import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';
import 'package:tienda_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/usecases/add_favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_state.dart';

class _MockRepo extends Mock implements FavoritesRepository {}

void main() {
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

  FavoritesCubit build() => FavoritesCubit(
    getFavorites: GetFavorites(repo),
    addFavorite: AddFavorite(repo),
    removeFavorite: RemoveFavorite(repo),
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'si falla la lectura emite failure',
    setUp: () => when(
      () => repo.getFavorites(),
    ).thenAnswer((_) async => const Err(CacheFailure())),
    build: build,
    act: (c) => c.load(),
    expect: () => [
      const FavoritesState(status: FavoritesStatus.loading),
      const FavoritesState(
        status: FavoritesStatus.failure,
        failure: CacheFailure(),
      ),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'si falla el guardado conserva la lista y emite failure',
    setUp: () => when(
      () => repo.add(any()),
    ).thenAnswer((_) async => const Err(CacheFailure())),
    build: build,
    act: (c) =>
        c.toggle(id: 1, title: 'x', price: 1, thumbnail: '', tags: const []),
    expect: () => [
      const FavoritesState(
        status: FavoritesStatus.failure,
        failure: CacheFailure(),
      ),
    ],
    verify: (_) => verifyNever(() => repo.getFavorites()),
  );
}
