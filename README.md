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
  `lib/features/products/domain/utils/top_tags.dart`. Su documentación define las reglas
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
