import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tienda_app/core/database/app_database.dart';
import 'package:tienda_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:tienda_app/features/favorites/data/models/favorite_model.dart';

void main() {
  late Database db;
  late FavoritesLocalDataSourceImpl source;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    source = FavoritesLocalDataSourceImpl(db);
  });

  tearDown(() => db.close());

  FavoriteModel fav(int id, DateTime addedAt, List<String> tags) =>
      FavoriteModel(
        id: id,
        title: 'Producto $id',
        price: id * 1.5,
        thumbnail: 'https://cdn/$id.webp',
        tags: tags,
        addedAt: addedAt,
      );

  test('guarda y lee todos los campos, con etiquetas en orden', () async {
    final addedAt = DateTime.utc(2026, 10, 1, 12);
    await source.upsert(fav(1, addedAt, ['beauty', 'mascara']));

    final all = await source.getAll();

    expect(all, hasLength(1));
    final f = all.single;
    expect(f.id, 1);
    expect(f.title, 'Producto 1');
    expect(f.price, 1.5);
    expect(f.thumbnail, 'https://cdn/1.webp');
    expect(f.tags, ['beauty', 'mascara']);
    expect(f.addedAt.toUtc(), addedAt);
  });

  test('ordena del más reciente al más antiguo', () async {
    await source.upsert(fav(1, DateTime.utc(2026, 1, 1), []));
    await source.upsert(fav(2, DateTime.utc(2026, 3, 1), []));
    await source.upsert(fav(3, DateTime.utc(2026, 2, 1), []));

    final ids = (await source.getAll()).map((f) => f.id);

    expect(ids, [2, 3, 1]);
  });

  test('las etiquetas se comparten entre favoritos (sin duplicados)', () async {
    await source.upsert(fav(1, DateTime.utc(2026), ['beauty', 'mascara']));
    await source.upsert(fav(2, DateTime.utc(2026), ['Beauty', 'eyeshadow']));

    final tags = await db.query('tags', orderBy: 'name');

    expect(tags.map((r) => r['name']), ['beauty', 'eyeshadow', 'mascara']);
  });

  test(
    'borrar un favorito elimina sus relaciones y etiquetas huérfanas',
    () async {
      await source.upsert(fav(1, DateTime.utc(2026), ['beauty', 'mascara']));
      await source.upsert(fav(2, DateTime.utc(2026), ['beauty']));

      await source.delete(1);

      expect((await source.getAll()).map((f) => f.id), [2]);
      expect(
        await db.query('favorite_tags', where: 'favorite_id = 1'),
        isEmpty,
      );
      final tags = await db.query('tags');
      expect(tags.map((r) => r['name']), ['beauty']);
    },
  );

  test(
    'volver a guardar un favorito reemplaza sus datos y etiquetas',
    () async {
      await source.upsert(fav(1, DateTime.utc(2026, 1), ['a', 'b']));
      await source.upsert(fav(1, DateTime.utc(2026, 2), ['c']));

      final all = await source.getAll();

      expect(all, hasLength(1));
      expect(all.single.tags, ['c']);
      expect(all.single.addedAt.toUtc(), DateTime.utc(2026, 2));
    },
  );

  test('las etiquetas repetidas en un producto se guardan una vez', () async {
    await source.upsert(fav(1, DateTime.utc(2026), ['a', 'A', 'a']));

    expect((await source.getAll()).single.tags, ['a']);
  });

  test('base vacía retorna lista vacía', () async {
    expect(await source.getAll(), isEmpty);
  });
}
