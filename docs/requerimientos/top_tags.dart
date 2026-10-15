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
// List<String> topTags(List<String> tags, int k) {
//   // TODO(candidato): implementar.
//   throw UnimplementedError();
// }

// Solución:
List<String> topTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return <String>[];

  final counts = <String, int>{};
  for (final tag in tags) {
    final key = tag.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final limit = k < counts.length ? k : counts.length;

  if (limit > _selectionLimit) {
    final entries = counts.entries.toList()..sort(_compareEntries);
    return entries.take(limit).map((entry) => entry.key).toList();
  }

  final best = <MapEntry<String, int>>[];
  for (final entry in counts.entries) {
    if (best.length == limit && _compareEntries(entry, best.last) >= 0) {
      continue;
    }
    var i = best.length;
    best.add(entry);
    while (i > 0 && _compareEntries(best[i], best[i - 1]) < 0) {
      final swap = best[i];
      best[i] = best[i - 1];
      best[i - 1] = swap;
      i--;
    }
    if (best.length > limit) best.removeLast();
  }

  return best.map((entry) => entry.key).toList();
}

const int _selectionLimit = 8;

int _compareEntries(MapEntry<String, int> a, MapEntry<String, int> b) {
  final byCount = b.value.compareTo(a.value);
  return byCount != 0 ? byCount : a.key.compareTo(b.key);
}
