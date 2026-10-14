import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tienda_app/features/catalog/domain/product.dart';
import 'package:tienda_app/features/favorites/data/sqlite_favorites_repository.dart';

Product product(int id, {double price = 9.99}) => Product(
  id: id,
  title: 'Producto $id',
  price: price,
  thumbnail: 'https://example.com/$id.webp',
  tags: ['Beauty', 'Beauty', 'mascara'],
);

void main() {
  sqfliteFfiInit();
  late Database db;
  late SqliteFavoritesRepository repository;
  late Directory temp;
  late String dbPath;
  Future<Database> open() => databaseFactoryFfi.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: SqliteFavoritesRepository.createSchema,
    ),
  );
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('tienda_test_');
    dbPath = '${temp.path}/favorites.db';
    db = await open();
    repository = SqliteFavoritesRepository(db);
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  test('persists all fields, tags and date across reopening', () async {
    final date = DateTime.utc(2026, 10, 14, 12);
    await repository.add(product(1), date);
    await db.close();
    db = await open();
    repository = SqliteFavoritesRepository(db);
    final item = (await repository.getFavorites()).single;
    expect(item.product.id, 1);
    expect(item.product.title, 'Producto 1');
    expect(item.product.price, 9.99);
    expect(item.product.thumbnail, 'https://example.com/1.webp');
    expect(item.product.tags, ['Beauty', 'Beauty', 'mascara']);
    expect(item.addedAt, date);
  });
  test('most recent first; idempotent add; remove cascades tags', () async {
    await repository.add(product(1), DateTime.utc(2026, 1));
    await repository.add(product(2), DateTime.utc(2026, 2));
    await repository.add(product(1), DateTime.utc(2026, 3));
    expect((await repository.getFavorites()).map((f) => f.product.id), [2, 1]);
    await repository.remove(1);
    expect(await db.query('favorite_tags', where: 'favorite_id = 1'), isEmpty);
    await repository.remove(2);
    expect(await repository.getFavorites(), isEmpty);
  });
  test('transaction rollback and foreign key constraints', () async {
    await expectLater(
      repository.add(product(1, price: -1), DateTime.now()),
      throwsA(anything),
    );
    expect(await repository.getFavorites(), isEmpty);
    expect(await db.query('favorite_tags'), isEmpty);
    await expectLater(
      db.insert('favorite_tags', {
        'favorite_id': 100,
        'position': 0,
        'tag': 'a',
      }),
      throwsA(anything),
    );
  });
}
