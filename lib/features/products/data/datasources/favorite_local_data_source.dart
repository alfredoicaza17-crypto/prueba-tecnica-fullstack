import 'package:sqflite/sqflite.dart';

import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/product.dart';

class FavoriteLocalDataSource {
  final Future<Database> database;

  FavoriteLocalDataSource(this.database);

  Future<List<FavoriteProduct>> getFavorites() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT f.id, f.title, f.price, f.thumbnail, f.added_at,
             t.tag AS tag
      FROM favorites AS f
      LEFT JOIN favorite_tags AS t ON t.favorite_id = f.id
      ORDER BY f.added_at DESC, f.id ASC, t.tag_index ASC
    ''');
    final favorites = <int, FavoriteProduct>{};

    for (final row in rows) {
      final id = row['id'] as int;
      final favorite = favorites.putIfAbsent(
        id,
        () => FavoriteProduct(
          product: Product(
            id: id,
            title: row['title'] as String,
            price: (row['price'] as num).toDouble(),
            thumbnail: row['thumbnail'] as String,
            tags: <String>[],
          ),
          addedAt: DateTime.parse(row['added_at'] as String),
        ),
      );
      final tag = row['tag'] as String?;
      if (tag != null) favorite.product.tags.add(tag);
    }

    return favorites.values.toList();
  }

  Future<bool> isFavorite(int productId) async {
    final db = await database;
    final rows = await db.query(
      'favorites',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> addFavorite(Product product) async {
    final db = await database;
    await db.transaction((transaction) async {
      final existing = await transaction.query(
        'favorites',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [product.id],
        limit: 1,
      );
      if (existing.isNotEmpty) return;

      await transaction.insert('favorites', {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
        'added_at': DateTime.now().toUtc().toIso8601String(),
      });

      for (var index = 0; index < product.tags.length; index++) {
        await transaction.insert('favorite_tags', {
          'favorite_id': product.id,
          'tag_index': index,
          'tag': product.tags[index],
        });
      }
    });
  }

  Future<void> removeFavorite(int productId) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [productId]);
  }
}
