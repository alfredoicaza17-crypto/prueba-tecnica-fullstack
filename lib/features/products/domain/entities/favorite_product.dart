import 'product.dart';

class FavoriteProduct {
  final Product product;
  final DateTime addedAt;

  const FavoriteProduct({required this.product, required this.addedAt});
}
