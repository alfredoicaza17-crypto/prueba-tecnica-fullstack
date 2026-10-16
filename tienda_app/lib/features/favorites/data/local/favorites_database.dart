import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FavoritesDatabase {
  FavoritesDatabase._();

  static const _databaseName = 'favorites.db';
  static const _databaseVersion = 1;

  static Future<Database>? _database;

  static Future<Database> get instance => _database ??= _openDatabase();

  static Future<Database> _openDatabase() async {
    final String databasePath;
    if (defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final supportDirectory = await getApplicationSupportDirectory();
      databasePath = join(supportDirectory.path, _databaseName);
    } else {
      databasePath = join(await getDatabasesPath(), _databaseName);
    }
    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
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
            FOREIGN KEY (favorite_id) REFERENCES favorites (id)
              ON DELETE CASCADE
          )
        ''');
        await database.execute(
          'CREATE INDEX favorites_added_at_idx ON favorites (added_at DESC)',
        );
      },
    );
  }
}
