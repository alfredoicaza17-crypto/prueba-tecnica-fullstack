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


---

Crear un PR con la solución

---

## Solución implementada

TiendaApp es una aplicación Flutter para Android. Implementa RF-01 a RF-04 con
Material 3, etiquetas sin distinción de mayúsculas y favoritos persistentes.

### Ejecutar

Requisitos: Flutter **3.47.7** (Dart 3.13.5), Java 17 y Android SDK.
En Windows se puede desarrollar desde VS Code con las extensiones Dart y Flutter.

```sh
flutter pub get
flutter devices
flutter run -d <id-del-dispositivo>
```

Selecciona explícitamente el dispositivo si tienes un teléfono y un emulador
conectados. Desde VS Code, abre la carpeta del repositorio, selecciona el
dispositivo Android y presiona F5.

### Verificar

```sh
dart format --output=none --set-exit-if-changed lib test integration_test top_tags.dart
flutter analyze
flutter test --coverage
flutter test integration_test/favorites_flow_test.dart -d <id-del-emulador>
flutter build apk --debug
```

El APK se genera en `build/app/outputs/flutter-apk/app-debug.apk`.
La automatización de GitHub ejecuta formato, análisis y pruebas unitarias/widget.
La prueba de integración requiere un dispositivo Android y usa SQLite nativo.

### Arquitectura

```text
lib/
  main.dart                       composición de dependencias y apertura SQLite
  app.dart                        tema y navegación inicial
  core/presentation/              widgets compartidos
  features/
    catalog/
      domain/                     Product, contrato, caso de uso y topTags
      data/                       implementación HTTP de ProductRepository
      presentation/               controlador de estados, filtros y pantalla
    favorites/
      domain/                     Favorite, contrato y casos de uso
      data/                       repositorio SQLite
      presentation/               controlador compartido y pantalla offline
```

El dominio usa Dart puro y no depende de Flutter, HTTP ni SQLite. Los
controladores reciben casos de uso mediante constructor; los repositorios se
inyectan en la raíz de la aplicación. ChangeNotifier comunica los cambios a los
widgets. La pantalla de favoritos comparte el controlador con el catálogo.

La función original `top_tags.dart` conserva su firma y delega a la implementación
del dominio, que también usa la app. Cuenta con un mapa y ordena las etiquetas
únicas: tiempo O(n + u log u), memoria O(u). No modifica el argumento ni elimina
espacios o etiquetas vacías, porque el contrato no define esa normalización.

### Diseño relacional

- `favorites`: id (PK), title, price, thumbnail, added_at (microsegundos UTC).
- `favorite_tags`: favorite_id (FK con ON DELETE CASCADE), position, tag.
  La PK compuesta conserva el orden y permite etiquetas repetidas.
- Índice sobre added_at para ordenar desde la fecha más reciente.

Agregar un favorito y sus etiquetas usa una transacción. Repetir el agregado
no cambia su fecha original. Desmarcar elimina el producto y sus etiquetas.
Volver a marcarlo registra una fecha nueva. Las escrituras no se muestran como
exitosas antes de que SQLite las complete; los errores de almacenamiento se
comunican al usuario.

### Estados y conexión

El catálogo solicita `/products?limit=20`. Muestra carga, lista vacía,
error del servidor con reintento y un mensaje distinto para fallos de transporte
o tiempo de espera. Un timeout no demuestra ausencia de Internet: el mensaje
invita a revisar la conexión y reintentar.

Los favoritos leen únicamente la base local, incluso si el catálogo falla.
Título, precio y etiquetas siguen disponibles sin conexión. Las miniaturas son
URLs remotas y muestran un ícono alternativo cuando no se pueden descargar.
No se implementa caché del catálogo, paginación ni sincronización remota porque
no forman parte del enunciado.

### Pruebas

La interfaz usa una paleta neutra, catálogo en cuadrícula adaptable y chips con
la primera letra en mayúscula solo en presentación. Incluye skeletons con
shimmer, entrada de tarjetas, carga progresiva de imágenes y transiciones de
filtros/favoritos. Los efectos personalizados respetan la preferencia del sistema
de reducir animaciones. Con texto ampliado o pantallas pequeñas, el catálogo
cambia a filas para conservar la legibilidad.

En tablets el catálogo aumenta sus columnas y centra el contenido con ancho
máximo de 1120 px lógicos. Favoritos limita el ancho de lectura a 760 px.
Las pruebas de widgets cubren 320×568, 360×640, 430×932, 844×390,
600×960, 800×1280, 1024×768 y 1366×1024, incluyendo carga, errores,
lista vacía, títulos extensos y favoritos. También se comprueba texto ampliado.

- `top_tags_test.dart`: mayúsculas, desempates, límites, inmutabilidad y 500.000 etiquetas.
- `api_product_repository_test.dart`: URL, parsing, vacío, HTTP fallido, timeout y JSON inválido.
- `sqlite_favorites_repository_test.dart`: SQLite real, reapertura, fecha, orden,
  etiquetas, FK, borrado en cascada y transacciones.
- `catalog_widget_test.dart`: carga, filtro reversible, reintento, vacío,
  navegación, favoritos sin conexión y escritura fallida.
- `integration_test/favorites_flow_test.dart`: filtro y favorito en Android,
  cierre/reapertura SQLite y pantalla Favoritos con transporte HTTP desconectado.
  La API se sustituye por respuestas deterministas para no depender del servicio externo.
