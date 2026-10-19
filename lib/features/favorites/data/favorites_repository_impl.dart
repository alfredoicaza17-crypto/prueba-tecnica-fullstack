import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../products/domain/product.dart';
import '../domain/favorites.dart';

/// Esquema relacional: `favorites` (1) -> (N) `favorite_tags`.
class FavoritesRepositoryImpl implements FavoritesRepository {
  Database? _db;

  Future<Database> get _database async => _db ??= await openDatabase(
        p.join(await getDatabasesPath(), 'tienda.db'),
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE favorites (
              id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              price REAL NOT NULL,
              thumbnail TEXT NOT NULL,
              added_at INTEGER NOT NULL
            )''');
          await db.execute('''
            CREATE TABLE favorite_tags (
              favorite_id INTEGER NOT NULL
                REFERENCES favorites(id) ON DELETE CASCADE,
              tag TEXT NOT NULL,
              PRIMARY KEY (favorite_id, tag)
            )''');
        },
      );

  @override
  Future<void> add(Product product) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert(
        'favorites',
        {
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'thumbnail': product.thumbnail,
          'added_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final tag in product.tags.toSet()) {
        await txn.insert('favorite_tags', {'favorite_id': product.id, 'tag': tag},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<void> remove(int id) async {
    final db = await _database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Favorite>> getAll() async {
    final db = await _database;
    final rows = await db.query('favorites', orderBy: 'added_at DESC, id DESC');
    final tagRows = await db.query('favorite_tags');

    final tagsById = <int, List<String>>{};
    for (final r in tagRows) {
      (tagsById[r['favorite_id'] as int] ??= []).add(r['tag'] as String);
    }

    return rows.map((r) {
      final id = r['id'] as int;
      return Favorite(
        Product(
          id: id,
          title: r['title'] as String,
          price: (r['price'] as num).toDouble(),
          thumbnail: r['thumbnail'] as String,
          tags: tagsById[id] ?? [],
        ),
        DateTime.fromMillisecondsSinceEpoch(r['added_at'] as int),
      );
    }).toList();
  }
}
