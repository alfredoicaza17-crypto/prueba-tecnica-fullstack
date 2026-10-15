# TiendaApp

Los requerimientos originales de la prueba están en [`docs/requerimientos/README.md`](docs/requerimientos/README.md).

## Qué hace

| Requisito | Qué hace la app |
|---|---|
| RF-01 | Lista los 20 productos de `GET /products?limit=20&delay=2000`. |
| RF-02 | Muestra carga, error con botón **Reintentar**, lista vacía y un estado distinto cuando no hay conexión. |
| RF-03 | Muestra los 5 tags más populares como chips (`topTags`). Al tocar uno filtra la lista y al tocarlo de nuevo se quita el filtro. |
| RF-04 | Guarda favoritos en SQLite, del más nuevo al más viejo, con un mensaje cuando no hay ninguno. Se pueden quitar desde el listado o desde la pantalla de favoritos. |

## Cómo correr la aplicación

```bash
flutter pub get
flutter run
```

## Tests y análisis

```bash
flutter analyze
flutter test
```

Se ejecutan 116 tests.

## Cómo probar los estados

La URL del catálogo está en `lib/features/products/data/datasources/product_remote_datasource.dart`.

| Estado | Cómo provocarlo |
|---|---|
| Carga | Es la URL normal: `delay=2000` mantiene el indicador 2 segundos. |
| Error del servidor | Cambiar la URL a `https://dummyjson.com/http/500`. |
| Error 404 | Cambiar la URL a `https://dummyjson.com/http/404`. |
| Lista vacía | Cambiar la URL a `https://dummyjson.com/products/search?q=zzzzzz`. |
| Sin conexión | Apagar el wifi del emulador de Android. |

Sin conexión es cuando el celular no llega al servidor. Error del servidor es cuando el servidor responde con un status distinto de 200.

URL normal, para dejarla como estaba:

```
https://dummyjson.com/products?limit=20&delay=2000
```

## Arquitectura

**Clean Architecture + Feature-First**: el código se agrupa por funcionalidad y dentro de cada una se separa en tres capas.

```
lib/
├── main.dart                  inyección de dependencias manual
├── app.dart                   MaterialApp y providers
├── core/                      piezas compartidas
│   ├── database/              esquema SQLite
│   ├── error/                 excepciones y fallos
│   ├── theme/                 tema de la app
│   ├── utils/
│   └── widgets/
└── features/
    ├── products/
    │   ├── domain/            entidades, contrato del repositorio, casos de uso, topTags
    │   ├── data/              modelo, datasource remoto, repositorio
    │   └── presentation/      cubit, página, widgets
    └── favorites/
        ├── domain/
        ├── data/              datasource local (SQLite), repositorio
        └── presentation/
```

- **domain** es Dart puro: no conoce Flutter, HTTP ni SQLite.
- **data** implementa los contratos del dominio. Las excepciones se traducen a fallos antes de subir.
- **presentation** usa `flutter_bloc` (Cubits). La interfaz solo habla con los casos de uso.

## Base de datos de favoritos

SQLite con tres tablas. `lib/core/database/app_database.dart`.

**`favorites`**: los productos guardados.

| Columna | Tipo | Nota |
|---|---|---|
| `id` | INTEGER | PK, es el id del producto |
| `title` | TEXT | |
| `price` | REAL | |
| `thumbnail_url` | TEXT | |
| `added_at` | INTEGER | fecha en milisegundos, tiene índice para ordenar del más nuevo al más viejo |

**`tags`**: los tags, sin repetir.

| Columna | Tipo | Nota |
|---|---|---|
| `id` | INTEGER | PK, autoincremental |
| `name` | TEXT | único, sin distinguir mayúsculas |

**`favorite_tags`**: une cada favorito con sus tags.

| Columna | Tipo | Nota |
|---|---|---|
| `favorite_id` | INTEGER | FK a `favorites`, se borra en cascada |
| `tag_id` | INTEGER | FK a `tags`, se borra en cascada |

La PK de `favorite_tags` es (`favorite_id`, `tag_id`). Guardar y quitar un favorito se hace en una transacción, y al quitarlo se borran los tags que se quedan sin uso.
