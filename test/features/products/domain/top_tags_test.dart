import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/domain/top_tags.dart' as app;

typedef TopTags = List<String> Function(List<String> tags, int k);

List<String> referenceTopTags(List<String> tags, int k) {
  if (k <= 0 || tags.isEmpty) return <String>[];
  final counts = <String, int>{};
  for (final tag in tags) {
    final key = tag.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
  return entries.take(k).map((entry) => entry.key).toList();
}

void main() {
  group('topTags', () {
    defineTopTagsTests(app.topTags);
  });
}

void defineTopTagsTests(TopTags topTags) {
  test('retorna las k etiquetas mas frecuentes del ejemplo del enunciado', () {
    final result = topTags(
      ['beauty', 'mascara', 'beauty', 'meat', 'meat', 'beauty'],
      2,
    );

    expect(result, ['beauty', 'meat']);
  });

  test('no distingue mayusculas y retorna en minusculas', () {
    final result = topTags(['Beauty', 'beauty', 'BEAUTY', 'Meat'], 2);

    expect(result, ['beauty', 'meat']);
  });

  test('ordena por frecuencia descendente', () {
    final result = topTags(['a', 'b', 'b', 'c', 'c', 'c'], 3);

    expect(result, ['c', 'b', 'a']);
  });

  test('en empate desempata alfabeticamente ascendente', () {
    final result = topTags(['zeta', 'beta', 'alfa', 'gamma'], 4);

    expect(result, ['alfa', 'beta', 'gamma', 'zeta']);
  });

  test('el desempate ignora las mayusculas', () {
    final result = topTags(['Zeta', 'alfa', 'Beta'], 3);

    expect(result, ['alfa', 'beta', 'zeta']);
  });

  test('retorna todas si k es mayor que las etiquetas distintas', () {
    final result = topTags(['a', 'b', 'a'], 10);

    expect(result, ['a', 'b']);
  });

  test('retorna vacia si k es cero', () {
    expect(topTags(['a', 'b'], 0), isEmpty);
  });

  test('retorna vacia si k es negativo', () {
    expect(topTags(['a', 'b'], -3), isEmpty);
  });

  test('retorna vacia si no hay etiquetas', () {
    expect(topTags(<String>[], 5), isEmpty);
  });

  test('con k igual a las etiquetas distintas retorna todas', () {
    final result = topTags(['a', 'b', 'b'], 2);

    expect(result, ['b', 'a']);
  });

  test('no modifica la lista recibida', () {
    final input = ['Beta', 'alfa', 'beta', 'ALFA', 'gamma'];
    final copy = List<String>.of(input);

    topTags(input, 2);

    expect(input, copy);
  });

  test('funciona con una lista inmutable', () {
    final input = List<String>.unmodifiable(['b', 'a', 'b']);

    expect(topTags(input, 1), ['b']);
  });

  test('retorna una lista nueva que se puede modificar', () {
    final result = topTags(['a'], 1);

    expect(() => result.add('x'), returnsNormally);
  });

  test('es eficiente con cientos de miles de etiquetas', () {
    final input = List<String>.generate(
      600000,
      (i) => i.isEven ? 'Common${i % 7}' : 'rare$i',
    );
    final stopwatch = Stopwatch()..start();

    final result = topTags(input, 5);

    stopwatch.stop();
    expect(result.length, 5);
    expect(result.every((tag) => tag.startsWith('common')), isTrue);
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });

  test('con muchos empates desempata alfabeticamente', () {
    final input = [for (var i = 20; i >= 1; i--) 'Tag${i.toString().padLeft(2, '0')}'];

    expect(topTags(input, 5), ['tag01', 'tag02', 'tag03', 'tag04', 'tag05']);
  });

  test('con k grande ordena por frecuencia y luego alfabeticamente', () {
    final input = [
      for (var i = 1; i <= 40; i++)
        for (var j = 0; j < i; j++) 'tag${i.toString().padLeft(2, '0')}',
    ];

    final result = topTags(input, 40);

    expect(result.length, 40);
    expect(result.first, 'tag40');
    expect(result.last, 'tag01');
  });

  test('el resultado es consistente alrededor del cambio de estrategia', () {
    final input = [
      for (var i = 1; i <= 30; i++)
        for (var j = 0; j < i % 7 + 1; j++) 'Tag${i.toString().padLeft(2, '0')}',
    ];
    final full = topTags(input, 30);

    for (final k in [1, 7, 8, 9, 10, 29, 30, 31]) {
      expect(topTags(input, k), full.take(k).toList());
    }
  });

  test('coincide con la referencia en miles de casos aleatorios', () {
    final random = Random(2024);

    for (var t = 0; t < 600; t++) {
      final alphabet = 1 + random.nextInt(t.isEven ? 6 : 120);
      final input = List<String>.generate(random.nextInt(300), (_) {
        final base = 'tag${random.nextInt(alphabet)}';
        return random.nextBool() ? base.toUpperCase() : base;
      });
      final snapshot = List<String>.of(input);

      for (final k in [-1, 0, 1, 5, 7, 8, 9, 10, 32, 33, 500]) {
        expect(topTags(input, k), referenceTopTags(input, k));
      }
      expect(input, snapshot);
    }
  });

  test('es eficiente cuando todas las etiquetas son distintas', () {
    final input = List<String>.generate(600000, (i) => 'tag$i');
    final stopwatch = Stopwatch()..start();

    final result = topTags(input, 5);

    stopwatch.stop();
    expect(result, referenceTopTags(input, 5));
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });

  test('es eficiente con nombres en orden alfabetico descendente', () {
    final input = List<String>.generate(
      600000,
      (i) => 't${(999999 - i).toString().padLeft(6, '0')}',
    );
    final stopwatch = Stopwatch()..start();

    final result = topTags(input, 8);

    stopwatch.stop();
    expect(result, referenceTopTags(input, 8));
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });

  test('es eficiente con k grande y muchas etiquetas distintas', () {
    final input = List<String>.generate(300000, (i) => 'Tag$i');
    final stopwatch = Stopwatch()..start();

    final result = topTags(input, 100000);

    stopwatch.stop();
    expect(result.length, 100000);
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });
}
