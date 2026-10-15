import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_state.dart';

import '../../../support/fixtures.dart';

class MockGetFavorites extends Mock implements GetFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockRemoveFavorite extends Mock implements RemoveFavorite {}

void main() {
  late MockGetFavorites getFavorites;
  late MockToggleFavorite toggleFavorite;
  late MockRemoveFavorite removeFavorite;

  final favorite = Favorite(
    id: mascara.id,
    title: mascara.title,
    price: mascara.price,
    thumbnail: mascara.thumbnail,
    tags: mascara.tags,
    addedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    getFavorites = MockGetFavorites();
    toggleFavorite = MockToggleFavorite();
    removeFavorite = MockRemoveFavorite();
    registerFallbackValue(mascara);
  });

  group('load', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'emite listo con los favoritos guardados',
      build: () {
        when(() => getFavorites()).thenAnswer((_) async => [favorite]);
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        FavoritesState(status: FavoritesStatus.ready, favorites: [favorite]),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emite listo con lista vacia si no hay favoritos',
      build: () {
        when(() => getFavorites()).thenAnswer((_) async => []);
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      act: (cubit) => cubit.load(),
      expect: () => [const FavoritesState(status: FavoritesStatus.ready)],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emite fallo si la base de datos falla',
      build: () {
        when(() => getFavorites()).thenThrow(const StorageFailure());
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      act: (cubit) => cubit.load(),
      expect: () => [const FavoritesState(status: FavoritesStatus.failure)],
    );
  });

  group('toggle', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'alterna el favorito y recarga la lista',
      build: () {
        when(() => toggleFavorite(any())).thenAnswer((_) async {});
        when(() => getFavorites()).thenAnswer((_) async => [favorite]);
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      act: (cubit) => cubit.toggle(mascara),
      expect: () => [
        FavoritesState(status: FavoritesStatus.ready, favorites: [favorite]),
      ],
      verify: (_) {
        verify(() => toggleFavorite(mascara)).called(1);
        verify(() => getFavorites()).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emite fallo y conserva la lista si alternar falla',
      build: () {
        when(() => toggleFavorite(any())).thenThrow(const StorageFailure());
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      seed: () =>
          FavoritesState(status: FavoritesStatus.ready, favorites: [favorite]),
      act: (cubit) => cubit.toggle(beef),
      expect: () => [
        FavoritesState(status: FavoritesStatus.failure, favorites: [favorite]),
      ],
    );
  });

  group('remove', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'quita el favorito por id y recarga la lista',
      build: () {
        when(() => removeFavorite(any())).thenAnswer((_) async {});
        when(() => getFavorites()).thenAnswer((_) async => []);
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      seed: () =>
          FavoritesState(status: FavoritesStatus.ready, favorites: [favorite]),
      act: (cubit) => cubit.remove(mascara.id),
      expect: () => [const FavoritesState(status: FavoritesStatus.ready)],
      verify: (_) {
        verify(() => removeFavorite(mascara.id)).called(1);
        verify(() => getFavorites()).called(1);
        verifyNever(() => toggleFavorite(any()));
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emite fallo y conserva la lista si quitar falla',
      build: () {
        when(() => removeFavorite(any())).thenThrow(const StorageFailure());
        return FavoritesCubit(getFavorites, toggleFavorite, removeFavorite);
      },
      seed: () =>
          FavoritesState(status: FavoritesStatus.ready, favorites: [favorite]),
      act: (cubit) => cubit.remove(mascara.id),
      expect: () => [
        FavoritesState(status: FavoritesStatus.failure, favorites: [favorite]),
      ],
      verify: (_) => verifyNever(() => getFavorites()),
    );
  });

  test('isFavorite indica si el producto esta en la lista', () {
    final state = FavoritesState(
      status: FavoritesStatus.ready,
      favorites: [favorite],
    );

    expect(state.isFavorite(mascara.id), isTrue);
    expect(state.isFavorite(beef.id), isFalse);
  });
}
