import 'tienda_app/lib/top_tags.dart' as implementation;

/// RF-03 · Etiquetas populares.
///
/// Retorna las [k] etiquetas más frecuentes de [tags], en minúsculas.
/// [tags] contiene las etiquetas (`tags`) de todos los productos cargados.
///
/// Reglas:
/// - Al contar no se distinguen mayúsculas: `Beauty` y `beauty` son la misma
///   etiqueta y se retorna como `beauty`.
/// - Orden: frecuencia descendente; en empate, orden alfabético ascendente.
/// - Si [k] es mayor que la cantidad de etiquetas distintas, retorna todas.
/// - Si [k] es menor o igual a 0, retorna una lista vacía.
/// - No modifica la lista recibida.
/// - Debe ser eficiente: se evaluará con cientos de miles de etiquetas.
/// - Implementación propia: sin paquetes externos.
///
/// Ejemplo:
/// `topTags(['beauty', 'mascara', 'beauty', 'meat', 'meat', 'beauty'], 2)`
/// → `['beauty', 'meat']`
List<String> topTags(List<String> tags, int k) {
  return implementation.topTags(tags, k);
}
