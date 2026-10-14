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
List<String> topTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return [];

  // 1. Contar las frecuencias, ignorando mayúsculas.
  final Map<String, int> frequencyMap = {};

  for (final tag in tags) {
    final normalizedTag = tag.toLowerCase();
    frequencyMap[normalizedTag] =
        (frequencyMap[normalizedTag] ?? 0) + 1;
  }

  // 2. Comparador: positivo si a es mejor que b.
  // Mejor = mayor frecuencia; empate = alfabéticamente menor.
  int compareTags(String a, String b) {
    final frequencyComparison =
    frequencyMap[a]!.compareTo(frequencyMap[b]!);

    if (frequencyComparison != 0) {
      return frequencyComparison;
    }

    // Si hay empate, la etiqueta alfabéticamente menor
    // es mejor.
    return b.compareTo(a);
  }

  // 3. Min-heap: el elemento menos favorable queda en la raíz.
  final List<String> heap = [];

  void siftUp(int index) {
    while (index > 0) {
      final parent = (index - 1) ~/ 2;

      if (compareTags(heap[index], heap[parent]) >= 0) {
        break;
      }

      final temp = heap[index];
      heap[index] = heap[parent];
      heap[parent] = temp;

      index = parent;
    }
  }

  void siftDown(int index) {
    while (true) {
      final left = index * 2 + 1;
      final right = left + 1;
      var smallest = index;

      if (left < heap.length &&
          compareTags(heap[left], heap[smallest]) < 0) {
        smallest = left;
      }

      if (right < heap.length &&
          compareTags(heap[right], heap[smallest]) < 0) {
        smallest = right;
      }

      if (smallest == index) break;

      final temp = heap[index];
      heap[index] = heap[smallest];
      heap[smallest] = temp;

      index = smallest;
    }
  }

  // 4. Conservar solo las k mejores etiquetas.
  for (final tag in frequencyMap.keys) {
    if (heap.length < k) {
      heap.add(tag);
      siftUp(heap.length - 1);
    } else if (compareTags(tag, heap[0]) > 0) {
      heap[0] = tag;
      siftDown(0);
    }
  }

  // 5. Ordenar únicamente las etiquetas seleccionadas.
  heap.sort((a, b) => -compareTags(a, b));

  return heap;
}