import 'package:sqflite/sqflite.dart';
import 'package:tienda_app/features/favorites/data/local/favorites_database.dart';
import 'package:tienda_app/features/favorites/data/models/favorite.dart';
import 'package:tienda_app/features/products/data/models/product_dto.dart';

class FavoritesRepository {
  FavoritesRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? _defaultDatabaseProvider;

  final Future<Database> Function() _databaseProvider;

  static Future<Database> _defaultDatabaseProvider() =>
      FavoritesDatabase.instance;

  Future<List<Favorite>> getFavorites() async {
    final database = await _databaseProvider();
    return database.transaction((transaction) async {
      final favoriteRows = await transaction.query(
        'favorites',
        orderBy: 'added_at DESC, id DESC',
      );
      final tagRows = await transaction.query(
        'favorite_tags',
        orderBy: 'favorite_id ASC, tag COLLATE NOCASE ASC',
      );

      final tagsByFavoriteId = <int, List<String>>{};
      for (final row in tagRows) {
        final favoriteId = row['favorite_id'] as int;
        (tagsByFavoriteId[favoriteId] ??= []).add(row['tag'] as String);
      }

      return favoriteRows
          .map(
            (row) => Favorite.fromDatabase(
              row,
              tags: tagsByFavoriteId[row['id'] as int] ?? const [],
            ),
          )
          .toList(growable: false);
    });
  }

  Future<Set<int>> getFavoriteIds() async {
    final database = await _databaseProvider();
    final rows = await database.query('favorites', columns: ['id']);
    return rows.map((row) => row['id'] as int).toSet();
  }

  Future<void> addFavorite(ProductDto product) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
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
        'thumbnail_url': product.thumbnail,
        'added_at': DateTime.now().toUtc().millisecondsSinceEpoch,
      });

      for (final tag in product.tags.toSet()) {
        await transaction.insert('favorite_tags', {
          'favorite_id': product.id,
          'tag': tag,
        });
      }
    });
  }

  Future<void> removeFavorite(int productId) async {
    final database = await _databaseProvider();
    await database.transaction((transaction) async {
      await transaction.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [productId],
      );
    });
  }
}
