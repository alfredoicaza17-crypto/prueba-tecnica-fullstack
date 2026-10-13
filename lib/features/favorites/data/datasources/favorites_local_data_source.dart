import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../models/favorite_model.dart';

abstract interface class FavoritesLocalDataSource {
  Future<List<FavoriteModel>> getAll();

  Future<void> upsert(FavoriteModel favorite);

  Future<void> delete(int id);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl(this._db);

  final Database _db;

  @override
  Future<List<FavoriteModel>> getAll() => _guard(() async {
    final rows = await _db.query(
      'favorites',
      orderBy: 'added_at DESC, product_id DESC',
    );
    if (rows.isEmpty) return const [];

    // Una sola consulta para las etiquetas de todos los favoritos (sin N+1).
    final tagRows = await _db.rawQuery('''
          SELECT ft.favorite_id, t.name
          FROM favorite_tags ft
          JOIN tags t ON t.id = ft.tag_id
          ORDER BY ft.favorite_id, ft.position
        ''');
    final tagsById = <int, List<String>>{};
    for (final r in tagRows) {
      (tagsById[r['favorite_id']! as int] ??= []).add(r['name']! as String);
    }

    return [
      for (final row in rows)
        FavoriteModel.fromRow(
          row,
          List.unmodifiable(tagsById[row['product_id']] ?? const []),
        ),
    ];
  });

  @override
  Future<void> upsert(FavoriteModel favorite) => _guard(
    () => _db.transaction((txn) async {
      await txn.insert(
        'favorites',
        favorite.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // REPLACE borra la fila previa y el CASCADE limpia favorite_tags,
      // pero lo hacemos explícito por claridad.
      await txn.delete(
        'favorite_tags',
        where: 'favorite_id = ?',
        whereArgs: [favorite.id],
      );

      final seen = <String>{};
      var position = 0;
      for (final raw in favorite.tags) {
        final name = raw.trim().toLowerCase();
        if (name.isEmpty || !seen.add(name)) continue;

        await txn.insert('tags', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        final tag = await txn.query(
          'tags',
          columns: ['id'],
          where: 'name = ?',
          whereArgs: [name],
        );
        await txn.insert('favorite_tags', {
          'favorite_id': favorite.id,
          'tag_id': tag.single['id'],
          'position': position++,
        });
      }
    }),
  );

  @override
  Future<void> delete(int id) => _guard(
    () => _db.transaction((txn) async {
      await txn.delete('favorites', where: 'product_id = ?', whereArgs: [id]);
      // Etiquetas que ya no usa ningún favorito.
      await txn.rawDelete('''
            DELETE FROM tags
            WHERE id NOT IN (SELECT DISTINCT tag_id FROM favorite_tags)
          ''');
    }),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw CacheException(e);
    }
  }
}
