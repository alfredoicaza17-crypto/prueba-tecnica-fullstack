import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tienda_app/core/database/app_database.dart';
import 'package:tienda_app/features/favorites/data/datasources/favorite_local_datasource.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';

import '../../../support/fixtures.dart';

Future<int> count(Database db, String table) async {
  final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
  return rows.first['total'] as int;
}

void main() {
  late Database db;
  late FavoriteLocalDataSourceImpl dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openAppDatabase(path: inMemoryDatabasePath);
    dataSource = FavoriteLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('esquema', () {
    test('crea las tablas favorites, tags y favorite_tags', () async {
      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
      );
      final names = rows.map((row) => row['name']).toSet();

      expect(names, {'favorites', 'tags', 'favorite_tags'});
    });

    test('tiene las claves foraneas activadas', () async {
      final rows = await db.rawQuery('PRAGMA foreign_keys');

      expect(rows.first['foreign_keys'], 1);
    });

    test('rechaza una relacion que apunta a filas inexistentes', () async {
      await expectLater(
        db.insert('favorite_tags', {'favorite_id': 99, 'tag_id': 99}),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('insert y getFavorites', () {
    test('guarda id, titulo, precio, miniatura, fecha y etiquetas', () async {
      final addedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

      await dataSource.insert(mascara, addedAt);
      final favorites = await dataSource.getFavorites();

      expect(favorites.length, 1);
      final favorite = favorites.single;
      expect(favorite.id, mascara.id);
      expect(favorite.title, mascara.title);
      expect(favorite.price, mascara.price);
      expect(favorite.thumbnail, mascara.thumbnail);
      expect(favorite.addedAt, addedAt);
      expect(favorite.tags, ['beauty', 'mascara']);
    });

    test('ordena del mas reciente al mas antiguo', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));
      await dataSource.insert(beef, DateTime(2026, 3, 1));
      await dataSource.insert(eyeliner, DateTime(2026, 2, 1));

      final favorites = await dataSource.getFavorites();

      expect(favorites.map((f) => f.id), [beef.id, eyeliner.id, mascara.id]);
    });

    test('con la misma fecha el id mas alto va primero', () async {
      final moment = DateTime(2026, 1, 1);
      await dataSource.insert(mascara, moment);
      await dataSource.insert(beef, moment);

      final favorites = await dataSource.getFavorites();

      expect(favorites.map((f) => f.id), [beef.id, mascara.id]);
    });

    test('devuelve lista vacia si no hay favoritos', () async {
      expect(await dataSource.getFavorites(), isEmpty);
    });

    test('un producto sin etiquetas se guarda con lista vacia', () async {
      const plain = Product(
        id: 50,
        title: 'Sin etiquetas',
        price: 1,
        tags: [],
        thumbnail: 't',
      );

      await dataSource.insert(plain, DateTime(2026, 1, 1));
      final favorites = await dataSource.getFavorites();

      expect(favorites.single.tags, isEmpty);
    });

    test('insertar dos veces el mismo producto no lo duplica', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));
      await dataSource.insert(mascara, DateTime(2026, 6, 1));

      final favorites = await dataSource.getFavorites();

      expect(favorites.length, 1);
      expect(favorites.single.addedAt, DateTime(2026, 1, 1));
      expect(favorites.single.tags, ['beauty', 'mascara']);
    });
  });

  group('relacion con etiquetas', () {
    test('las etiquetas compartidas se guardan una sola vez', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));
      await dataSource.insert(eyeliner, DateTime(2026, 1, 2));

      expect(await count(db, 'tags'), 3);
      expect(await count(db, 'favorite_tags'), 4);
    });

    test('las etiquetas no distinguen mayusculas', () async {
      const upper = Product(
        id: 60,
        title: 'u',
        price: 1,
        tags: ['Beauty'],
        thumbnail: 't',
      );
      await dataSource.insert(mascara, DateTime(2026, 1, 1));
      await dataSource.insert(upper, DateTime(2026, 1, 2));

      expect(await count(db, 'tags'), 2);
    });

    test('ignora etiquetas vacias', () async {
      const blank = Product(
        id: 61,
        title: 'b',
        price: 1,
        tags: ['', '  ', 'ok'],
        thumbnail: 't',
      );

      await dataSource.insert(blank, DateTime(2026, 1, 1));
      final favorites = await dataSource.getFavorites();

      expect(favorites.single.tags, ['ok']);
    });
  });

  group('delete', () {
    test('elimina el favorito y sus relaciones', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));

      await dataSource.delete(mascara.id);

      expect(await dataSource.getFavorites(), isEmpty);
      expect(await count(db, 'favorites'), 0);
      expect(await count(db, 'favorite_tags'), 0);
    });

    test('elimina las etiquetas que quedan sin uso', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));

      await dataSource.delete(mascara.id);

      expect(await count(db, 'tags'), 0);
    });

    test('conserva las etiquetas que aun usa otro favorito', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));
      await dataSource.insert(eyeliner, DateTime(2026, 1, 2));

      await dataSource.delete(mascara.id);
      final favorites = await dataSource.getFavorites();

      expect(favorites.single.id, eyeliner.id);
      expect(favorites.single.tags, ['beauty', 'eyeliner']);
      expect(await count(db, 'tags'), 2);
    });

    test('eliminar un id inexistente no falla', () async {
      await expectLater(dataSource.delete(999), completes);
    });
  });

  group('isFavorite', () {
    test('es verdadero solo para productos guardados', () async {
      await dataSource.insert(mascara, DateTime(2026, 1, 1));

      expect(await dataSource.isFavorite(mascara.id), isTrue);
      expect(await dataSource.isFavorite(beef.id), isFalse);
    });
  });

  group('persistencia sin conexion', () {
    late Directory directory;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('tienda_app_db_');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('los favoritos siguen ahi al cerrar y reabrir la base', () async {
      final path = p.join(directory.path, 'favoritos.db');

      final first = await openAppDatabase(path: path);
      await FavoriteLocalDataSourceImpl(first).insert(
        beef,
        DateTime(2026, 5, 1),
      );
      await first.close();

      final second = await openAppDatabase(path: path);
      final favorites = await FavoriteLocalDataSourceImpl(second).getFavorites();
      await second.close();

      expect(favorites.single.title, beef.title);
      expect(favorites.single.tags, ['groceries', 'meat']);
    });
  });
}
