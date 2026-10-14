import 'package:flutter/foundation.dart';

import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorite_repository.dart';

class FavoriteBloc extends ChangeNotifier {
  final FavoriteRepository repository;
  final Set<int> _pendingProductIds = {};

  FavoriteBloc({required this.repository});

  List<FavoriteProduct> favoriteProducts = [];
  bool isLoading = false;
  String? errorMessage;

  bool isFavorite(int productId) =>
      favoriteProducts.any((favorite) => favorite.product.id == productId);

  bool isPending(int productId) => _pendingProductIds.contains(productId);

  Future<void> loadFavorites() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      favoriteProducts = await repository.getFavorites();
    } catch (error) {
      errorMessage = 'No se pudieron cargar los favoritos: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Product product) async {
    if (!_pendingProductIds.add(product.id)) return;
    notifyListeners();

    try {
      if (isFavorite(product.id)) {
        await repository.removeFavorite(product.id);
        favoriteProducts.removeWhere(
          (favorite) => favorite.product.id == product.id,
        );
      } else {
        await repository.addFavorite(product);
        favoriteProducts = await repository.getFavorites();
      }
      errorMessage = null;
    } catch (error) {
      errorMessage = 'No se pudo actualizar el favorito: $error';
      rethrow;
    } finally {
      _pendingProductIds.remove(product.id);
      notifyListeners();
    }
  }
}
