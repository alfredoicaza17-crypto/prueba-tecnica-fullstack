import 'package:tienda_app/features/favorites/domain/entities/favorite.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';

const mascara = Product(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  price: 9.99,
  thumbnail: '',
  tags: ['beauty', 'mascara'],
);

const eyeshadow = Product(
  id: 2,
  title: 'Eyeshadow Palette with Mirror',
  price: 19.99,
  thumbnail: '',
  tags: ['beauty', 'eyeshadow'],
);

const apple = Product(
  id: 3,
  title: 'Apple',
  price: 1.99,
  thumbnail: '',
  tags: ['fruits'],
);

const sampleProducts = [mascara, eyeshadow, apple];

Favorite favoriteFrom(Product p, DateTime addedAt) => Favorite(
  id: p.id,
  title: p.title,
  price: p.price,
  thumbnail: p.thumbnail,
  tags: p.tags,
  addedAt: addedAt,
);
