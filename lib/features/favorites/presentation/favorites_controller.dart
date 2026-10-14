import 'package:flutter/foundation.dart';
import '../../catalog/domain/product.dart';
import '../domain/favorite.dart';
import '../domain/manage_favorites.dart';

class FavoritesController extends ChangeNotifier {
  final ManageFavorites manage;
  FavoritesController(this.manage);
  List<Favorite> items = [];
  bool loading = true;
  String? error;
  final Set<int> pending = {};
  bool _disposed = false;
  bool contains(int id) => items.any((item) => item.product.id == id);
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    _emit();
    try {
      items = await manage.load();
    } catch (_) {
      error = 'No se pudieron leer los favoritos guardados.';
    }
    loading = false;
    _emit();
  }

  Future<bool> toggle(Product product) async {
    if (loading || error != null || pending.contains(product.id)) return false;
    pending.add(product.id);
    _emit();
    try {
      if (contains(product.id)) {
        await manage.remove(product.id);
      } else {
        await manage.add(product);
      }
      items = await manage.load();
      return true;
    } catch (_) {
      // Reload after a possible read failure so UI does not assume the write failed.
      await load();
      return false;
    } finally {
      pending.remove(product.id);
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
