import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/favorite.dart';

abstract interface class FavoriteLocalDataSource {
  Future<List<Favorite>> getFavorites();

  Future<bool> isFavorite(int productId);

  Future<void> insert(Product product, DateTime addedAt);

  Future<void> delete(int productId);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  const FavoriteLocalDataSourceImpl(this._db);

  final Database _db;

  @override
  Future<List<Favorite>> getFavorites() => _guard(() async {
        final favoriteRows = await _db.query(
          'favorites',
          orderBy: 'added_at DESC, id DESC',
        );
        final tagRows = await _db.rawQuery('''
          SELECT ft.favorite_id AS favorite_id, t.name AS name
          FROM favorite_tags ft
          JOIN tags t ON t.id = ft.tag_id
          ORDER BY t.name
        ''');

        final tagsByFavorite = <int, List<String>>{};
        for (final row in tagRows) {
          tagsByFavorite
              .putIfAbsent(row['favorite_id'] as int, () => [])
              .add(row['name'] as String);
        }

        return [
          for (final row in favoriteRows)
            Favorite(
              id: row['id'] as int,
              title: row['title'] as String,
              price: (row['price'] as num).toDouble(),
              thumbnail: row['thumbnail_url'] as String,
              tags: tagsByFavorite[row['id'] as int] ?? const [],
              addedAt: DateTime.fromMillisecondsSinceEpoch(
                row['added_at'] as int,
              ),
            ),
        ];
      });

  @override
  Future<bool> isFavorite(int productId) => _guard(() async {
        final rows = await _db.query(
          'favorites',
          columns: ['id'],
          where: 'id = ?',
          whereArgs: [productId],
          limit: 1,
        );
        return rows.isNotEmpty;
      });

  @override
  Future<void> insert(Product product, DateTime addedAt) => _guard(() {
        return _db.transaction((txn) async {
          await txn.insert(
            'favorites',
            {
              'id': product.id,
              'title': product.title,
              'price': product.price,
              'thumbnail_url': product.thumbnail,
              'added_at': addedAt.millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );

          for (final tag in product.tags.where((t) => t.trim().isNotEmpty)) {
            await txn.insert(
              'tags',
              {'name': tag},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
            final tagRows = await txn.query(
              'tags',
              columns: ['id'],
              where: 'name = ?',
              whereArgs: [tag],
              limit: 1,
            );
            await txn.insert(
              'favorite_tags',
              {'favorite_id': product.id, 'tag_id': tagRows.first['id']},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        });
      });

  @override
  Future<void> delete(int productId) => _guard(() {
        return _db.transaction((txn) async {
          await txn.delete(
            'favorites',
            where: 'id = ?',
            whereArgs: [productId],
          );
          await txn.rawDelete(
            'DELETE FROM tags WHERE id NOT IN '
            '(SELECT tag_id FROM favorite_tags)',
          );
        });
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException {
      throw const StorageException();
    }
  }
}
