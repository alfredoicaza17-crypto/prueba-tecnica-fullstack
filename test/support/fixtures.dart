import 'package:tienda_app/features/products/domain/entities/product.dart';

const mascara = Product(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  price: 9.99,
  tags: ['beauty', 'mascara'],
  thumbnail: 'https://cdn.dummyjson.com/mascara.webp',
);

const eyeliner = Product(
  id: 2,
  title: 'Eyeliner',
  price: 19.99,
  tags: ['beauty', 'eyeliner'],
  thumbnail: 'https://cdn.dummyjson.com/eyeliner.webp',
);

const beef = Product(
  id: 3,
  title: 'Beef Steak',
  price: 12.5,
  tags: ['groceries', 'meat'],
  thumbnail: 'https://cdn.dummyjson.com/beef.webp',
);

const chicken = Product(
  id: 4,
  title: 'Chicken Meat',
  price: 9.0,
  tags: ['groceries', 'meat', 'fresh'],
  thumbnail: 'https://cdn.dummyjson.com/chicken.webp',
);

const sampleProducts = [mascara, eyeliner, beef, chicken];

const sampleTopTags = ['beauty', 'groceries', 'meat', 'eyeliner', 'fresh'];

const productsJson = '''
{
  "products": [
    {
      "id": 1,
      "title": "Essence Mascara Lash Princess",
      "price": 9.99,
      "tags": ["beauty", "mascara"],
      "thumbnail": "https://cdn.dummyjson.com/mascara.webp"
    },
    {
      "id": 2,
      "title": "Eyeliner",
      "price": 20,
      "tags": ["beauty", "eyeliner"],
      "thumbnail": "https://cdn.dummyjson.com/eyeliner.webp"
    }
  ],
  "total": 194,
  "skip": 0,
  "limit": 20
}
''';
