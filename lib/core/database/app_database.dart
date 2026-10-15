import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const databaseName = 'tienda_app.db';
const databaseVersion = 1;

Future<Database> openAppDatabase({String? path}) async {
  final location = path ?? p.join(await getDatabasesPath(), databaseName);
  return openDatabase(
    location,
    version: databaseVersion,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: (db, version) async {
      final batch = db.batch();
      batch.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          price REAL NOT NULL,
          thumbnail_url TEXT NOT NULL,
          added_at INTEGER NOT NULL
        )
      ''');
      batch.execute(
        'CREATE INDEX idx_favorites_added_at ON favorites (added_at DESC)',
      );
      batch.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE COLLATE NOCASE
        )
      ''');
      batch.execute('''
        CREATE TABLE favorite_tags (
          favorite_id INTEGER NOT NULL
            REFERENCES favorites (id) ON DELETE CASCADE,
          tag_id INTEGER NOT NULL
            REFERENCES tags (id) ON DELETE CASCADE,
          PRIMARY KEY (favorite_id, tag_id)
        ) WITHOUT ROWID
      ''');
      batch.execute(
        'CREATE INDEX idx_favorite_tags_tag_id ON favorite_tags (tag_id)',
      );
      await batch.commit(noResult: true);
    },
  );
}
