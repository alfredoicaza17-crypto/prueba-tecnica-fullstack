import 'package:sqflite/sqflite.dart';
import '../../catalog/domain/product.dart';
import '../domain/favorite.dart';
import '../domain/favorites_repository.dart';

class SqliteFavoritesRepository implements FavoritesRepository {
  final Database db;
  SqliteFavoritesRepository(this.db);

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL CHECK(price >= 0),
        thumbnail TEXT NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE favorite_tags (
        favorite_id INTEGER NOT NULL REFERENCES favorites(id) ON DELETE CASCADE,
        position INTEGER NOT NULL,
        tag TEXT NOT NULL,
        PRIMARY KEY (favorite_id, position)
      )
    ''');
    await db.execute(
      'CREATE INDEX favorites_recent ON favorites(added_at DESC)',
    );
  }

  @override
  Future<void> add(Product product, DateTime addedAt) =>
      db.transaction((txn) async {
        // Repeated additions preserve the complete original snapshot and date.
        final existing = await txn.query(
          'favorites',
          columns: ['id'],
          where: 'id = ?',
          whereArgs: [product.id],
        );
        if (existing.isNotEmpty) return;
        await txn.insert('favorites', {
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'thumbnail': product.thumbnail,
          'added_at': addedAt.toUtc().microsecondsSinceEpoch,
        });
        final batch = txn.batch();
        for (var i = 0; i < product.tags.length; i++) {
          batch.insert('favorite_tags', {
            'favorite_id': product.id,
            'position': i,
            'tag': product.tags[i],
          });
        }
        await batch.commit(noResult: true);
      });

  @override
  Future<void> remove(int productId) async {
    await db.delete('favorites', where: 'id = ?', whereArgs: [productId]);
  }

  @override
  Future<List<Favorite>> getFavorites() => db.transaction((txn) async {
    final rows = await txn.query(
      'favorites',
      orderBy: 'added_at DESC, id DESC',
    );
    final tags = await txn.query(
      'favorite_tags',
      orderBy: 'favorite_id, position',
    );
    final byId = <int, List<String>>{};
    for (final tag in tags) {
      byId
          .putIfAbsent(tag['favorite_id'] as int, () => [])
          .add(tag['tag'] as String);
    }
    return rows
        .map(
          (row) => Favorite(
            product: Product(
              id: row['id'] as int,
              title: row['title'] as String,
              price: (row['price'] as num).toDouble(),
              thumbnail: row['thumbnail'] as String,
              tags: byId[row['id']] ?? [],
            ),
            addedAt: DateTime.fromMicrosecondsSinceEpoch(
              row['added_at'] as int,
              isUtc: true,
            ),
          ),
        )
        .toList();
  });
}
