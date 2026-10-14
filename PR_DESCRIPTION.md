# TiendaApp: catálogo, etiquetas populares y favoritos

## Resumen

Implementa una aplicación Flutter de catálogo que consume productos de DummyJSON. La solución separa presentación, dominio y acceso a datos siguiendo Clean Architecture y organiza el código por feature. Incluye estados de carga y error, filtro por etiquetas populares y favoritos persistidos localmente en SQLite.

## Implementación

### Arquitectura

- `domain`: entidades `Product` y `FavoriteProduct`, contratos de repositorio, caso de uso de productos y cálculo de etiquetas populares.
- `data`: datasource remoto para DummyJSON, datasource local para favoritos, modelos, repositorios concretos y configuración del esquema SQLite en `AppDatabase`.
- `presentation`: páginas del catálogo y de favoritos, con `ProductBloc` y `FavoriteBloc` para gestionar el estado y las acciones de UI.
- `main.dart`: inicializa Flutter y compone las dependencias; no contiene SQL ni definición de tablas.

### Requisitos funcionales

- **RF-01 — Listado:** muestra miniatura, título y precio de los productos obtenidos de DummyJSON.
- **RF-02 — Estados:** diferencia carga, lista vacía, errores del servidor y problemas de conectividad; permite reintentar la carga.
- **RF-03 — Etiquetas populares:** calcula las cinco etiquetas más frecuentes con `topTags`, sin dependencias externas. Normaliza mayúsculas/minúsculas, resuelve empates alfabéticamente y selecciona las `k` mejores mediante un min-heap. Los chips filtran el catálogo y permiten quitar el filtro al volver a seleccionarlos.
- **RF-04 — Favoritos:** cada producto se puede agregar o quitar de favoritos. SQLite guarda el ID, título, precio, miniatura, fecha de agregado y etiquetas. Las etiquetas viven en una tabla relacional `favorite_tags`, con clave foránea y eliminación en cascada. La pantalla Favoritos lee desde la base local, ordena del más reciente al más antiguo, muestra título, precio y etiquetas, y presenta un estado vacío.

## Pruebas

- `flutter test` — suite completa aprobada.
- `flutter analyze` — los archivos de la implementación analizados no reportan problemas. El análisis global conserva avisos `avoid_print` en el datasource remoto.

## Nota sobre el límite de productos

El datasource remoto está configurado actualmente con `limit=20&delay=2000`. El retraso se conserva para simular una red lenta.
