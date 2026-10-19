import 'package:flutter_test/flutter_test.dart';

import '../top_tags.dart';

void main() {
  test('ordena por frecuencia y desempata alfabéticamente', () {
    final result = topTags(['Beauty', 'skin', 'beauty', 'makeup', 'makeup'], 5);

    expect(result, ['beauty', 'makeup', 'skin']);
  });

  test('limita el resultado a k', () {
    final result = topTags(['a', 'b', 'c', 'd', 'e', 'f'], 5);
    expect(result, ['a', 'b', 'c', 'd', 'e']);
  });

  test('retorna vacío con k no positivo y no modifica la entrada', () {
    final tags = ['Beauty', 'beauty'];

    expect(topTags(tags, 0), isEmpty);
    expect(tags, ['Beauty', 'beauty']);
  });
}
