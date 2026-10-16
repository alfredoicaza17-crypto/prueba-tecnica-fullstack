import 'package:flutter_test/flutter_test.dart';

import '../../top_tags.dart';

void main() {
  group('topTags', () {
    test('normalizes case and sorts by frequency then alphabetically', () {
      expect(
        topTags(['Beauty', 'mascara', 'beauty', 'Meat', 'meat', 'BEAUTY'], 3),
        ['beauty', 'meat', 'mascara'],
      );
    });

    test('returns all distinct tags when k exceeds their count', () {
      expect(topTags(['B', 'a', 'b'], 10), ['b', 'a']);
    });

    test('returns an empty list when k is not positive', () {
      expect(topTags(['beauty'], 0), isEmpty);
      expect(topTags(['beauty'], -1), isEmpty);
    });

    test('does not mutate the input list', () {
      final tags = ['Beauty', 'beauty', 'mascara'];
      final original = List<String>.of(tags);

      topTags(tags, 2);

      expect(tags, original);
    });

    test('handles a large tag list', () {
      final tags = <String>[]
        ..addAll(List<String>.filled(100000, 'beauty'))
        ..addAll(List<String>.filled(50000, 'mascara'));

      expect(topTags(tags, 2), ['beauty', 'mascara']);
    });
  });
}
