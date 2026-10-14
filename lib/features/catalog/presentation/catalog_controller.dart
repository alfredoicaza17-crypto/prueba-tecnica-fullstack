import 'package:flutter/foundation.dart';
import '../domain/get_products.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import '../domain/top_tags.dart';

enum CatalogStatus { loading, ready, empty, offline, error }

class CatalogController extends ChangeNotifier {
  final GetProducts getProducts;
  CatalogController(this.getProducts);
  CatalogStatus status = CatalogStatus.loading;
  List<Product> products = [];
  List<String> popularTags = [];
  String? selectedTag;
  bool _disposed = false;
  List<Product> get visibleProducts => selectedTag == null
      ? products
      : products
            .where((p) => p.tags.any((t) => t.toLowerCase() == selectedTag))
            .toList();
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    status = CatalogStatus.loading;
    _emit();
    try {
      products = List.unmodifiable(await getProducts());
      popularTags = topTags(products.expand((p) => p.tags).toList(), 5);
      if (!popularTags.contains(selectedTag)) selectedTag = null;
      status = products.isEmpty ? CatalogStatus.empty : CatalogStatus.ready;
    } on CatalogException catch (e) {
      status = e.failure == CatalogFailure.offline
          ? CatalogStatus.offline
          : CatalogStatus.error;
    } catch (_) {
      status = CatalogStatus.error;
    }
    _emit();
  }

  void selectTag(String tag) {
    selectedTag = selectedTag == tag ? null : tag;
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
