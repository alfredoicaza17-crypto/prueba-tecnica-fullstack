import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Abre la base SQLite de la app y aplica migraciones.
///
/// Esquema (ver RESPUESTAS.md · P2):
/// - `favorites`: un producto marcado como favorito.
/// - `tags`: catálogo de etiquetas, cada nombre una sola vez.
/// - `favorite_tags`: relación N:M entre favoritos y etiquetas.
class AppDatabase {
  AppDatabase._();

  static const fileName = 'tienda_app.db';
  static const version = 1;

  /// [factory] y [path] permiten usar una base en memoria en los tests.
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), fileName);

    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => _createV1(db),
      ),
    );
  }

  static Future<void> _createV1(Database db) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE favorites (
          product_id    INTEGER PRIMARY KEY,
          title         TEXT    NOT NULL,
          price         REAL    NOT NULL CHECK (price >= 0),
          thumbnail_url TEXT    NOT NULL,
          added_at      INTEGER NOT NULL
        )
      ''')
      ..execute(
        'CREATE INDEX idx_favorites_added_at ON favorites (added_at DESC)',
      )
      ..execute('''
        CREATE TABLE tags (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT    NOT NULL UNIQUE
        )
      ''')
      ..execute('''
        CREATE TABLE favorite_tags (
          favorite_id INTEGER NOT NULL
            REFERENCES favorites (product_id) ON DELETE CASCADE,
          tag_id      INTEGER NOT NULL
            REFERENCES tags (id) ON DELETE CASCADE,
          position    INTEGER NOT NULL,
          PRIMARY KEY (favorite_id, tag_id)
        )
      ''')
      ..execute('CREATE INDEX idx_favorite_tags_tag ON favorite_tags (tag_id)');
    await batch.commit(noResult: true);
  }
}
