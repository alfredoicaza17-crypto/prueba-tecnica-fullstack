import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/data/models/product_dto.dart';
import 'package:tienda_app/features/products/data/models/products_response_dto.dart';

void main() {
  const productJson = <String, dynamic>{
    'id': 1,
    'title': 'Essence Mascara Lash Princess',
    'description': 'The Essence Mascara Lash Princess is a popular mascara.',
    'category': 'beauty',
    'price': 9.99,
    'discountPercentage': 10.48,
    'rating': 2.56,
    'stock': 99,
    'thumbnail': 'https://example.com/thumbnail.webp',
    'images': ['https://example.com/product.webp'],
  };

  group('ProductDto', () {
    test('parses a product from JSON', () {
      final product = ProductDto.fromJson(productJson);

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.price, 9.99);
      expect(product.images, ['https://example.com/product.webp']);
    });

    test('serializes a product to JSON', () {
      final product = ProductDto.fromJson(productJson);

      expect(product.toJson(), productJson);
    });
  });

  group('ProductsResponseDto', () {
    test('parses the product collection and pagination metadata', () {
      final response = ProductsResponseDto.fromJson({
        'products': [productJson],
        'total': 194,
        'skip': 0,
        'limit': 30,
      });

      expect(response.products, hasLength(1));
      expect(response.products.single.id, 1);
      expect(response.total, 194);
      expect(response.skip, 0);
      expect(response.limit, 30);
    });

    test('serializes the response to JSON', () {
      final response = ProductsResponseDto.fromJson({
        'products': [productJson],
        'total': 194,
        'skip': 0,
        'limit': 30,
      });

      expect(response.toJson(), {
        'products': [productJson],
        'total': 194,
        'skip': 0,
        'limit': 30,
      });
    });
  });
}
