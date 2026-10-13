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
  if (k <= 0 || tags.isEmpty) return const [];

  // 1. Conteo en una sola pasada: O(n). Solo se lee [tags], nunca se modifica.
  final counts = <String, int>{};
  for (final tag in tags) {
    final key = tag.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final entries = counts.entries.toList(growable: false);

  // 2a. Si se piden todas (o casi todas), ordenar todo: O(m log m).
  if (k >= entries.length) {
    entries.sort(_byRank);
    return [for (final e in entries) e.key];
  }

  // 2b. Si k es pequeño frente a las m etiquetas distintas, un min-heap de
  // tamaño k evita ordenar todo: O(m log k).
  final heap = _BoundedMinHeap(k);
  for (final e in entries) {
    heap.offer(e);
  }
  final top = heap.toList()..sort(_byRank);
  return [for (final e in top) e.key];
}

/// Orden final: frecuencia descendente y, en empate, alfabético ascendente.
/// Retorna < 0 si [a] debe ir antes que [b].
int _byRank(MapEntry<String, int> a, MapEntry<String, int> b) {
  final byCount = b.value.compareTo(a.value);
  return byCount != 0 ? byCount : a.key.compareTo(b.key);
}

/// Min-heap (por [_byRank] invertido) que conserva solo los k mejores.
/// La raíz es siempre el "peor" de los k guardados, así que un candidato
/// nuevo solo entra si supera a la raíz.
class _BoundedMinHeap {
  _BoundedMinHeap(this._capacity);

  final int _capacity;
  final List<MapEntry<String, int>> _items = [];

  /// `true` si [a] está peor rankeado que [b] (debe estar más cerca de la raíz).
  bool _worse(MapEntry<String, int> a, MapEntry<String, int> b) =>
      _byRank(a, b) > 0;

  void offer(MapEntry<String, int> entry) {
    if (_items.length < _capacity) {
      _items.add(entry);
      _siftUp(_items.length - 1);
    } else if (_worse(_items.first, entry)) {
      _items[0] = entry;
      _siftDown(0);
    }
  }

  List<MapEntry<String, int>> toList() => List.of(_items);

  void _siftUp(int i) {
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (!_worse(_items[i], _items[parent])) return;
      _swap(i, parent);
      i = parent;
    }
  }

  void _siftDown(int i) {
    final n = _items.length;
    while (true) {
      final left = 2 * i + 1;
      final right = left + 1;
      var worst = i;
      if (left < n && _worse(_items[left], _items[worst])) worst = left;
      if (right < n && _worse(_items[right], _items[worst])) worst = right;
      if (worst == i) return;
      _swap(i, worst);
      i = worst;
    }
  }

  void _swap(int a, int b) {
    final tmp = _items[a];
    _items[a] = _items[b];
    _items[b] = tmp;
  }
}
