import 'package:flutter/foundation.dart';

import '../../favorites/domain/favorites.dart';
import '../domain/product.dart';
import '../domain/top_tags.dart';

enum ProductsStatus { loading, loaded, error, offline }

class ProductsController extends ChangeNotifier {
  final ProductRepository _products;
  final FavoritesRepository _favorites;

  ProductsController(this._products, this._favorites);

  ProductsStatus status = ProductsStatus.loading;
  List<Product> _all = [];
  Set<int> favoriteIds = {};
  String? selectedTag;

  List<String> get popularTags =>
      topTags(_all.expand((p) => p.tags).toList(), 5);

  List<Product> get products => selectedTag == null
      ? _all
      : _all
          .where((p) => p.tags.any((t) => t.toLowerCase() == selectedTag))
          .toList();

  Future<void> load() async {
    status = ProductsStatus.loading;
    notifyListeners();
    try {
      _all = await _products.getProducts();
      status = ProductsStatus.loaded;
    } on NetworkException {
      status = ProductsStatus.offline;
    } catch (_) {
      status = ProductsStatus.error;
    }
    if (status == ProductsStatus.loaded) {
      // Un fallo de la base local no debe impedir ver el listado.
      try {
        favoriteIds = (await _favorites.getAll()).map((f) => f.product.id).toSet();
      } catch (e) {
        debugPrint('No se pudieron cargar los favoritos: $e');
      }
    }
    notifyListeners();
  }

  void toggleTag(String tag) {
    selectedTag = selectedTag == tag ? null : tag;
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      if (favoriteIds.contains(product.id)) {
        await _favorites.remove(product.id);
        favoriteIds.remove(product.id);
      } else {
        await _favorites.add(product);
        favoriteIds.add(product.id);
      }
    } catch (e) {
      debugPrint('No se pudo actualizar el favorito: $e');
    }
    notifyListeners();
  }
}
