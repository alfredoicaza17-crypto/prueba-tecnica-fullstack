/// RF-03 · Etiquetas populares.
///
/// Retorna las [k] etiquetas más frecuentes de [tags], en minúsculas.
///
/// Reglas:
/// - Al contar no se distinguen mayúsculas.
/// - Orden: frecuencia descendente; en empate, orden alfabético ascendente.
/// - Si [k] es mayor que la cantidad de etiquetas distintas, retorna todas.
/// - Si [k] es menor o igual a 0, retorna una lista vacía.
/// - No modifica la lista recibida.
/// - Implementación propia, sin paquetes externos.
List<String> topTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return const [];

  final frequencies = <String, int>{};
  for (final tag in tags) {
    final normalized = tag.toLowerCase();
    frequencies[normalized] = (frequencies[normalized] ?? 0) + 1;
  }

  final ordered = frequencies.entries.toList()
    ..sort((a, b) {
      final byFrequency = b.value.compareTo(a.value);
      return byFrequency != 0 ? byFrequency : a.key.compareTo(b.key);
    });
  return ordered.take(k).map((entry) => entry.key).toList(growable: false);
}
