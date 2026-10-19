import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../favorites/domain/usecases/get_favorites.dart';
import '../../favorites/domain/usecases/remove_favorite.dart';
import '../../favorites/domain/usecases/save_favorite.dart';

import 'package:tienda_app/top_tags.dart' as tag_algorithm;

import '../domain/entities/product.dart';
import '../domain/usecases/get_products.dart';

enum ProductListStatus { loading, content, empty, error, offline }

class ProductListController extends ChangeNotifier {
  ProductListController(
    this._getProducts,
    this._getFavorites,
    this._saveFavorite,
    this._removeFavorite,
  );
  final GetProducts _getProducts;
  final GetFavorites _getFavorites;
  final SaveFavorite _saveFavorite;
  final RemoveFavorite _removeFavorite;

  ProductListStatus status = ProductListStatus.loading;
  String? message;
  String? selectedTag;
  List<Product> _all = const [];
  Set<int> _favoriteIds = {};

  List<Product> get products => selectedTag == null
      ? _all
      : _all
            .where(
              (p) => p.tags.any(
                (t) => t.trim().toLowerCase() == selectedTag!.toLowerCase(),
              ),
            )
            .toList();
  List<String> get tags => tag_algorithm.topTags(
    _all.expand((product) => product.tags).toList(growable: false),
    5,
  );
  bool isFavorite(Product product) => _favoriteIds.contains(product.id);

  Future<void> load() async {
    status = ProductListStatus.loading;
    message = null;
    notifyListeners();
    final result = await _getProducts();
    if (!result.isSuccess) {
      message = result.failure!.message;
      status = result.failure is NetworkFailure
          ? ProductListStatus.offline
          : ProductListStatus.error;
      notifyListeners();
      return;
    }
    _all = result.products!;
    final favorites = await _getFavorites();
    if (favorites.isSuccess) {
      _favoriteIds = favorites.favorites!.map((e) => e.id).toSet();
    }
    status = _all.isEmpty ? ProductListStatus.empty : ProductListStatus.content;
    notifyListeners();
  }

  void toggleTag(String tag) {
    selectedTag = selectedTag?.toLowerCase() == tag.toLowerCase() ? null : tag;
    notifyListeners();
  }

  Future<Failure?> toggleFavorite(Product product) async {
    final saved = isFavorite(product);
    saved ? _favoriteIds.remove(product.id) : _favoriteIds.add(product.id);
    notifyListeners();
    final failure = saved
        ? await _removeFavorite(product.id)
        : await _saveFavorite(product);
    if (failure != null) {
      saved ? _favoriteIds.add(product.id) : _favoriteIds.remove(product.id);
      message = failure.message;
      notifyListeners();
    }
    return failure;
  }
}
