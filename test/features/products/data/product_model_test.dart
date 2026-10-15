import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('mapea todos los campos del enunciado', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'price': 9.99,
        'tags': ['beauty', 'mascara'],
        'thumbnail': 'https://cdn.dummyjson.com/t.webp',
      });

      expect(model.id, 1);
      expect(model.title, 'Essence Mascara Lash Princess');
      expect(model.price, 9.99);
      expect(model.tags, ['beauty', 'mascara']);
      expect(model.thumbnail, 'https://cdn.dummyjson.com/t.webp');
    });

    test('convierte un precio entero a double', () {
      final model = ProductModel.fromJson({
        'id': 2,
        'title': 'x',
        'price': 20,
        'tags': <String>[],
        'thumbnail': 't',
      });

      expect(model.price, 20.0);
      expect(model.price, isA<double>());
    });

    test('usa lista vacia si faltan las etiquetas', () {
      final model = ProductModel.fromJson({
        'id': 3,
        'title': 'x',
        'price': 1.5,
        'thumbnail': 't',
      });

      expect(model.tags, isEmpty);
    });

    test('usa cadena vacia si falta la miniatura', () {
      final model = ProductModel.fromJson({
        'id': 4,
        'title': 'x',
        'price': 1.5,
        'tags': <String>[],
      });

      expect(model.thumbnail, isEmpty);
    });

    test('lanza error si falta un campo obligatorio', () {
      expect(
        () => ProductModel.fromJson({'id': 5, 'price': 1.0}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
