import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/domain/usecases/top_tags.dart';

void main() {
  group('topTags', () {
    test('ejemplo de la documentación', () {
      expect(
        topTags(['beauty', 'mascara', 'beauty', 'meat', 'meat', 'beauty'], 2),
        ['beauty', 'meat'],
      );
    });

    test('no distingue mayúsculas y retorna en minúsculas', () {
      expect(topTags(['Beauty', 'beauty', 'BEAUTY', 'Meat', 'meat'], 2), [
        'beauty',
        'meat',
      ]);
    });

    test('en empate ordena alfabéticamente ascendente', () {
      expect(topTags(['c', 'b', 'a', 'b', 'c', 'a', 'd'], 3), ['a', 'b', 'c']);
    });

    test('el empate considera la versión en minúsculas', () {
      expect(topTags(['B', 'a'], 2), ['a', 'b']);
    });

    test('si k supera las etiquetas distintas retorna todas', () {
      expect(topTags(['x', 'y', 'x'], 10), ['x', 'y']);
    });

    test('k igual a la cantidad de distintas retorna todas', () {
      expect(topTags(['x', 'y', 'x'], 2), ['x', 'y']);
    });

    test('k <= 0 retorna lista vacía', () {
      expect(topTags(['a', 'b'], 0), isEmpty);
      expect(topTags(['a', 'b'], -3), isEmpty);
    });

    test('lista vacía retorna lista vacía', () {
      expect(topTags(const [], 5), isEmpty);
    });

    test('no modifica la lista recibida', () {
      final input = ['B', 'a', 'B', 'c'];
      final copy = List.of(input);
      topTags(input, 2);
      expect(input, copy);
    });

    test('acepta listas inmodificables', () {
      expect(topTags(const ['a', 'b', 'a'], 1), ['a']);
    });

    test('el resultado coincide con ordenar todo (comparación aleatoria)', () {
      final random = Random(42);
      for (var round = 0; round < 200; round++) {
        final tags = List.generate(random.nextInt(300), (_) {
          final t = 'tag${random.nextInt(40)}';
          return random.nextBool() ? t.toUpperCase() : t;
        });
        final k = random.nextInt(50) - 5;
        expect(topTags(tags, k), _naiveTopTags(tags, k), reason: 'k=$k');
      }
    });

    test('es eficiente con cientos de miles de etiquetas', () {
      final random = Random(7);
      final tags = List.generate(500000, (_) => 'Tag${random.nextInt(100000)}');

      final sw = Stopwatch()..start();
      final result = topTags(tags, 5);
      sw.stop();

      expect(result, _naiveTopTags(tags, 5));
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });
  });
}

/// Implementación de referencia, simple y obviamente correcta.
List<String> _naiveTopTags(List<String> tags, int k) {
  if (k <= 0) return [];
  final counts = <String, int>{};
  for (final t in tags) {
    counts.update(t.toLowerCase(), (c) => c + 1, ifAbsent: () => 1);
  }
  final keys = counts.keys.toList()
    ..sort((a, b) {
      final c = counts[b]!.compareTo(counts[a]!);
      return c != 0 ? c : a.compareTo(b);
    });
  return keys.take(k).toList();
}
