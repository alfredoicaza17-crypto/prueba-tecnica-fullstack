import 'package:flutter_test/flutter_test.dart';
import '../top_tags.dart';

void main() {
  test('frequency, case folding and alphabetical tie breaking', () {
    expect(topTags(['Beauty', 'meat', 'beauty', 'Meat', 'z', 'a'], 5), [
      'beauty',
      'meat',
      'a',
      'z',
    ]);
  });
  test('empty, nonpositive k and k greater than unique count', () {
    expect(topTags([], 5), isEmpty);
    expect(topTags(['a'], 0), isEmpty);
    expect(topTags(['a'], -1), isEmpty);
    expect(topTags(['a', 'a'], 20), ['a']);
  });
  test('does not mutate input or invent trimming rules', () {
    final input = List<String>.unmodifiable([' A ', '', 'a', '']);
    expect(topTags(input, 10), ['', ' a ', 'a']);
    expect(input, [' A ', '', 'a', '']);
  });
  test('hundreds of thousands of labels', () {
    final input = List.generate(500000, (i) => 'tag${i % 1000}');
    final expected = List.generate(1000, (i) => 'tag$i')..sort();
    expect(topTags(input, 5), expected.take(5).toList());
  });
}
