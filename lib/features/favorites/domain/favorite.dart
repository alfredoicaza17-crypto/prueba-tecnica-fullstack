import '../../catalog/domain/product.dart';

class Favorite {
  final Product product;
  final DateTime addedAt;
  const Favorite({required this.product, required this.addedAt});
}
