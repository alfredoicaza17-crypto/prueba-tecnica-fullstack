# App Flutter TiendaApp

Desarrolla **TiendaApp**, un catálogo de productos que consume la API pública
[DummyJSON](https://dummyjson.com/docs/products).

Una UI simple con widgets de Material es suficiente: evaluamos **estructura, correcto funcionamiento y tests**.

La app debe desarrollarse siguiendo los principios de **Clean Architecture** y el patrón **Feature-First**.


## API

```text
GET https://dummyjson.com/products?limit=20
```

```json
{
  "products": [
    {
      "id": 1,
      "title": "Essence Mascara Lash Princess",
      "price": 9.99,
      "tags": ["beauty", "mascara"],
      "thumbnail": "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp"
    }
  ],
  "total": 194, "skip": 0, "limit": 20
}
```

> 💡 Agrega `&delay=2000` para simular una red lenta.

---

## Requisitos funcionales

### RF-01 · Listado
Muestra los primeros 20 productos con miniatura, título y precio.

### RF-02 · Estados
La pantalla de listado muestra: **cargando**, **error** entendible con botón **Reintentar**,
**lista vacía**, y un mensaje de **sin conexión** distinto del error del servidor.

### RF-03 · Etiquetas populares
- Sobre el listado, muestra como *chips* las **5 etiquetas más frecuentes** entre los productos
  cargados (campo `tags`).
- Al tocar una etiqueta, el listado muestra **solo los productos que la tienen**; al tocarla de
  nuevo, se quita el filtro.
- El cálculo va en la función **`topTags`** que ya existe en
  `top_tags.dart`. Su documentación define las reglas
  exactas (desempate, mayúsculas, casos borde). **No cambies su firma**
- Implementación propia, **sin paquetes externos** para esta función.

### RF-04 · Favoritos
- Cada producto del listado tiene un ícono para **marcar/desmarcar** como favorito.
- Los favoritos se guardan en una base de datos **SQLite** local, con **`sqflite` o `drift`**
  (no uses `shared_preferences`, `hive` ni `isar`: evaluamos tu diseño relacional).
- Por cada favorito se guarda: id, título, precio, URL de la miniatura, **fecha en que se agregó**
  y **sus etiquetas**.
- Una pantalla **Favoritos** (accesible desde el AppBar del listado) los muestra del **más reciente
  al más antiguo**, con título, precio y etiquetas; funciona **sin conexión**; muestra un mensaje si está vacía.
- Explica tu esquema en `RESPUESTAS.md` (pregunta P2).


---

Crear un PR con la solución


---

## Solución

### Ejecutar

```bash
flutter pub get
flutter run      # Android / iOS / Linux desktop
flutter test     # 61 tests: unit, integración con SQLite y widget/E2E
```

Requisitos: Flutter 3.41 (Dart 3.11). En Linux desktop y en los tests se usa
`sqflite_common_ffi`, que necesita `libsqlite3`.

### Arquitectura

Feature-First y, dentro de cada feature, las capas de Clean Architecture. Las
dependencias apuntan siempre hacia el dominio.

```text
lib/
├── main.dart               # arranque: abre SQLite y arma dependencias
├── app/
│   ├── app.dart            # MaterialApp + BlocProviders
│   └── injection.dart      # composition root (DI manual, sin service locator)
├── core/
│   ├── error/              # Failure (sealed), Result<T> (Ok/Err), excepciones
│   ├── database/           # AppDatabase: esquema y migraciones
│   └── widgets/            # MessageView, ProductThumbnail
└── features/
    ├── products/           # RF-01, RF-02, RF-03
    │   ├── domain/         # Product · ProductRepository · GetProducts · topTags
    │   ├── data/           # ProductModel · RemoteDataSource (http) · RepositoryImpl
    │   └── presentation/   # ProductsCubit · ProductsPage · widgets
    └── favorites/          # RF-04
        ├── domain/         # Favorite · FavoritesRepository · Get/Add/RemoveFavorite
        ├── data/           # FavoriteModel · LocalDataSource (sqflite) · RepositoryImpl
        └── presentation/   # FavoritesCubit · FavoritesPage
```

| Capa | Responsabilidad | Depende de |
|------|-----------------|------------|
| `domain` | Entidades, contratos de repositorio y casos de uso. Dart puro. | nada |
| `data` | Habla con la red y con SQLite. Convierte excepciones en `Failure`. | `domain` |
| `presentation` | Cubits (estado) y widgets. | `domain` |
| `app` | Une las implementaciones concretas. | todo |

### Decisiones

- **Errores sin excepciones en el dominio.** La capa de datos lanza
  `NetworkException`, `ServerException` o `CacheException`, y el repositorio
  las convierte en un `Result` con un `Failure` (una clase `sealed`). Así, el
  compilador obliga a manejar cada caso con `switch`.
- **Sin conexión vs. error del servidor (RF-02).** `SocketException`,
  `ClientException` y timeout cuentan como `NetworkFailure`. Un status distinto
  de 200 o un JSON inválido cuenta como `ServerFailure`. No se usa
  `connectivity_plus`: estar conectado a una red Wi-Fi no garantiza tener
  internet, y lo que importa es si la petición llegó.
- **Recarga sin perder datos.** El pull-to-refresh mantiene la lista visible.
  Si falla, se avisa con un SnackBar en lugar de mostrar la pantalla de error.
  También se ignora un `load()` mientras ya hay otro en curso.
- **`topTags` (RF-03).** Se movió a
  `lib/features/products/domain/usecases/top_tags.dart`, con la misma firma y
  la misma documentación. Cuenta las etiquetas en O(n) con un `Map` y, si `k`
  es menor que la cantidad de etiquetas distintas `m`, usa un min-heap de
  tamaño `k`: O(m log k) en vez de O(m log m). Se prueba contra una
  implementación de referencia con 200 casos aleatorios y con 500 000
  etiquetas.
- **Favoritos desacoplados de productos.** `FavoritesCubit.toggle` recibe
  datos planos, así que la feature `favorites` no importa nada de `products`.
  Si se toca dos veces mientras se guarda, el segundo toque se ignora.
- **Esquema SQLite (RF-04).** Ver [`RESPUESTAS.md`](RESPUESTAS.md) (P2).
- **DI manual.** Para dos features, un composition root explícito es más
  simple y transparente que `get_it`, y los tests inyectan *fakes* por
  constructor.

### Tests

| Tipo | Qué cubre |
|------|-----------|
| Unit | `topTags`, parseo del JSON, mapeo de errores de red y servidor, repositorios, casos de uso |
| Cubit (`bloc_test`) | Estados de carga, error, vacío y éxito; filtro por etiqueta; refresh; concurrencia |
| Integración | `FavoritesLocalDataSource` y `FavoritesCubit` contra SQLite real en memoria |
| Widget | Cada estado de `ProductsPage` y `FavoritesPage` |
| E2E (`app_flow_test`) | App completa con la red simulada: listar → filtrar → marcar favorito → reabrir sin red → ver favoritos |

La cobertura de líneas es de aproximadamente 90%. La CI
(`.github/workflows/ci.yml`) revisa el formato, corre `flutter analyze` y
ejecuta los tests en cada PR.

### Siguientes pasos

- Paginación con `skip` y scroll infinito, y caché del listado para mostrarlo
  sin conexión.
- Exponer los favoritos como `Stream` desde el repositorio, para que la UI
  reaccione sin recargar.
- Internacionalización con `intl` (formato de moneda y fechas según el locale).
