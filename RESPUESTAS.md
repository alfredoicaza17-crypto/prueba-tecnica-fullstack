# Respuestas

## P2 · Esquema de la base de datos de favoritos

Los favoritos se guardan en SQLite con `sqflite`. El esquema se crea en
[`lib/core/database/app_database.dart`](lib/core/database/app_database.dart).

```text
favorites                      favorite_tags                  tags
─────────────────────────      ──────────────────────────     ─────────────────
product_id    INTEGER PK  ◄──  favorite_id INTEGER FK         id   INTEGER PK
title         TEXT             tag_id      INTEGER FK  ──►    name TEXT UNIQUE
price         REAL             position    INTEGER
thumbnail_url TEXT             PK (favorite_id, tag_id)
added_at      INTEGER
```

```sql
CREATE TABLE favorites (
  product_id    INTEGER PRIMARY KEY,           -- id de DummyJSON
  title         TEXT    NOT NULL,
  price         REAL    NOT NULL CHECK (price >= 0),
  thumbnail_url TEXT    NOT NULL,
  added_at      INTEGER NOT NULL               -- epoch ms en UTC
);
CREATE INDEX idx_favorites_added_at ON favorites (added_at DESC);

CREATE TABLE tags (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL UNIQUE                 -- en minúsculas
);

CREATE TABLE favorite_tags (
  favorite_id INTEGER NOT NULL REFERENCES favorites (product_id) ON DELETE CASCADE,
  tag_id      INTEGER NOT NULL REFERENCES tags (id)              ON DELETE CASCADE,
  position    INTEGER NOT NULL,                -- conserva el orden original
  PRIMARY KEY (favorite_id, tag_id)
);
CREATE INDEX idx_favorite_tags_tag ON favorite_tags (tag_id);
```

### Decisiones

- **Relación N:M normalizada.** Un producto tiene varias etiquetas y una
  etiqueta pertenece a varios productos, así que se usa una tabla puente
  `favorite_tags` en lugar de guardar las etiquetas como texto separado por
  comas o como JSON. Así cada etiqueta se guarda una sola vez (`UNIQUE`), y se
  puede consultar "favoritos con la etiqueta X" con un `JOIN` indexado, sin
  `LIKE '%x%'`.
- **El id del producto es la clave primaria** de `favorites`. Un producto
  solo puede ser favorito una vez, y el chequeo "¿es favorito?" es una
  búsqueda por PK.
- **`position`** guarda el orden en que la API entrega las etiquetas, porque
  una relación SQL no tiene orden propio.
- **`added_at` como `INTEGER` (epoch ms, UTC).** Se ordena y compara como
  número y es independiente de la zona horaria. El índice
  `idx_favorites_added_at` sirve para el listado "del más reciente al más
  antiguo". En empate se desempata por `product_id DESC` para que el orden sea
  estable.
- **Integridad referencial.** Se activa `PRAGMA foreign_keys = ON` en
  `onConfigure` (SQLite la trae apagada por defecto). Al borrar un favorito,
  `ON DELETE CASCADE` limpia sus filas en `favorite_tags`, y en la misma
  transacción se eliminan las etiquetas que quedaron huérfanas.
- **Transacciones.** Guardar un favorito (fila + etiquetas + relaciones) y
  borrarlo son operaciones atómicas: no pueden quedar favoritos a medio
  guardar.
- **Lectura sin N+1.** La pantalla de favoritos hace dos consultas: una para
  los favoritos y otra que trae todas las etiquetas con un `JOIN`. Luego se
  agrupan en memoria, en vez de hacer una consulta por cada favorito.
- **Etiquetas en minúsculas**, con la misma regla que `topTags` (`Beauty` y
  `beauty` son la misma etiqueta). Las duplicadas dentro de un mismo producto
  se guardan una sola vez.
- **Precio como `REAL`.** Es lo que entrega la API y solo se muestra. Si la app
  hiciera cálculos de dinero (carrito, totales), lo guardaría en centavos como
  `INTEGER` para evitar errores de redondeo.
- **Migraciones.** `AppDatabase.version` y `onCreate` dejan preparado el
  `onUpgrade` para futuras versiones del esquema.
- **Funciona sin conexión.** La pantalla de favoritos lee solo de SQLite: se
  guardan título, precio, URL de la miniatura, fecha y etiquetas. Sin red, la
  miniatura muestra un ícono de reemplazo.

### Pruebas

`test/features/favorites/data/favorites_local_data_source_test.dart` corre
contra un SQLite real en memoria (`sqflite_common_ffi`). Verifica el orden por
fecha, que las etiquetas no se dupliquen, el borrado en cascada con limpieza de
huérfanas y el reemplazo al volver a guardar.
