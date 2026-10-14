import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const _databaseName = 'tienda_favorites.db';
  static const _databaseVersion = 1;

  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = path.join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: _configure,
      onCreate: _createSchema,
    );
  }

  Future<void> _configure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        thumbnail TEXT NOT NULL,
        added_at TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE favorite_tags (
        favorite_id INTEGER NOT NULL,
        tag_index INTEGER NOT NULL,
        tag TEXT NOT NULL,
        PRIMARY KEY (favorite_id, tag_index),
        FOREIGN KEY (favorite_id) REFERENCES favorites (id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute(
      'CREATE INDEX idx_favorites_added_at ON favorites (added_at DESC)',
    );
  }
}
