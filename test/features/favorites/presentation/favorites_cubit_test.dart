import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tienda_app/core/database/app_database.dart';
import 'package:tienda_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:tienda_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:tienda_app/features/favorites/domain/usecases/add_favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_state.dart';

/// Test de integración del cubit con el repositorio real sobre SQLite en
/// memoria: cubre el flujo completo de RF-04.
void main() {
  late Database db;
  late FavoritesCubit Function() buildCubit;
  var clock = DateTime.utc(2026, 1, 1);

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    final repo = FavoritesRepositoryImpl(FavoritesLocalDataSourceImpl(db));
    buildCubit = () => FavoritesCubit(
      getFavorites: GetFavorites(repo),
      addFavorite: AddFavorite(repo, now: () => clock),
      removeFavorite: RemoveFavorite(repo),
    );
  });

  tearDown(() => db.close());

  Future<void> toggle(FavoritesCubit c, int id) => c.toggle(
    id: id,
    title: 'P$id',
    price: 1,
    thumbnail: '',
    tags: const ['tag'],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'load con base vacía emite success sin favoritos',
    build: () => buildCubit(),
    act: (c) => c.load(),
    expect: () => [
      const FavoritesState(status: FavoritesStatus.loading),
      const FavoritesState(status: FavoritesStatus.success),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle agrega y luego quita',
    build: () => buildCubit(),
    act: (c) async {
      await c.load();
      await toggle(c, 1);
      expect(c.state.isFavorite(1), isTrue);
      await toggle(c, 1);
    },
    verify: (c) {
      expect(c.state.isFavorite(1), isFalse);
      expect(c.state.favorites, isEmpty);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'los favoritos quedan del más reciente al más antiguo',
    build: () => buildCubit(),
    act: (c) async {
      await c.load();
      clock = DateTime.utc(2026, 1, 1);
      await toggle(c, 1);
      clock = DateTime.utc(2026, 1, 2);
      await toggle(c, 2);
    },
    verify: (c) => expect(c.state.favorites.map((f) => f.id), [2, 1]),
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'un doble toque mientras se guarda no deshace el favorito',
    build: () => buildCubit(),
    act: (c) async {
      await c.load();
      await Future.wait([toggle(c, 1), toggle(c, 1)]);
    },
    verify: (c) => expect(c.state.isFavorite(1), isTrue),
  );
}
