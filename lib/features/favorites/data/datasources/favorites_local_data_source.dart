import 'package:sqflite/sqflite.dart';

import '../../../products/domain/entities/product.dart';
import '../../domain/entities/favorite_product.dart';

abstract interface class FavoritesLocalDataSource {
  Future<List<FavoriteProduct>> getFavorites();
  Future<void> addFavorite(Product product, DateTime addedAt);
  Future<void> removeFavorite(int productId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      '$databasePath/tienda_app.db',
      version: 1,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            thumbnail_url TEXT NOT NULL,
            added_at INTEGER NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE favorite_tags (
            favorite_id INTEGER NOT NULL,
            tag TEXT NOT NULL,
            PRIMARY KEY (favorite_id, tag),
            FOREIGN KEY (favorite_id) REFERENCES favorites(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _database!;
  }

  @override
  Future<void> addFavorite(Product product, DateTime addedAt) async {
    final database = await _db;
    await database.transaction((transaction) async {
      await transaction.insert('favorites', {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'thumbnail_url': product.thumbnailUrl,
        'added_at': addedAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await transaction.delete(
        'favorite_tags',
        where: 'favorite_id = ?',
        whereArgs: [product.id],
      );
      for (final tag in product.tags) {
        await transaction.insert('favorite_tags', {
          'favorite_id': product.id,
          'tag': tag,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<List<FavoriteProduct>> getFavorites() async {
    final rows = await (await _db).rawQuery('''
      SELECT f.id, f.title, f.price, f.thumbnail_url, f.added_at, t.tag
      FROM favorites f LEFT JOIN favorite_tags t ON t.favorite_id = f.id
      ORDER BY f.added_at DESC, t.tag ASC
    ''');
    final byId = <int, _FavoriteBuilder>{};
    for (final row in rows) {
      final id = row['id'] as int;
      final favorite = byId.putIfAbsent(
        id,
        () => _FavoriteBuilder(
          id: id,
          title: row['title'] as String,
          price: (row['price'] as num).toDouble(),
          thumbnailUrl: row['thumbnail_url'] as String,
          addedAt: DateTime.fromMillisecondsSinceEpoch(row['added_at'] as int),
        ),
      );
      final tag = row['tag'] as String?;
      if (tag != null) favorite.tags.add(tag);
    }
    return byId.values.map((item) => item.build()).toList(growable: false);
  }

  @override
  Future<void> removeFavorite(int productId) async {
    await (await _db).delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}

class _FavoriteBuilder {
  _FavoriteBuilder({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
    required this.addedAt,
  });
  final int id;
  final String title;
  final double price;
  final String thumbnailUrl;
  final DateTime addedAt;
  final tags = <String>[];

  FavoriteProduct build() => FavoriteProduct(
    id: id,
    title: title,
    price: price,
    thumbnailUrl: thumbnailUrl,
    tags: List.unmodifiable(tags),
    addedAt: addedAt,
  );
}
