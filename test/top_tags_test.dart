import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/domain/top_tags.dart';

void main() {
  test('ejemplo del enunciado', () {
    expect(
      topTags(['beauty', 'mascara', 'beauty', 'meat', 'meat', 'beauty'], 2),
      ['beauty', 'meat'],
    );
  });

  test('no distingue mayúsculas y retorna en minúsculas', () {
    expect(topTags(['Beauty', 'beauty', 'BEAUTY', 'a'], 1), ['beauty']);
  });

  test('empate se resuelve alfabéticamente', () {
    expect(topTags(['b', 'a', 'c'], 2), ['a', 'b']);
  });

  test('k mayor a las etiquetas distintas retorna todas', () {
    expect(topTags(['a', 'b', 'a'], 10), ['a', 'b']);
  });

  test('k <= 0 retorna vacía', () {
    expect(topTags(['a'], 0), isEmpty);
    expect(topTags(['a'], -1), isEmpty);
  });

  test('lista vacía y no modifica la entrada', () {
    expect(topTags([], 3), isEmpty);
    final input = ['b', 'A', 'a'];
    topTags(input, 2);
    expect(input, ['b', 'A', 'a']);
  });

  test('es eficiente con cientos de miles de etiquetas', () {
    final tags = List.generate(500000, (i) => 'tag${i % 1000}');
    expect(topTags(tags, 5).length, 5);
  });
}
