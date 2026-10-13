import '../../../../core/error/result.dart';
import '../entities/favorite.dart';

abstract interface class FavoritesRepository {
  /// Favoritos del más reciente al más antiguo.
  Future<Result<List<Favorite>>> getFavorites();

  Future<Result<void>> add(Favorite favorite);

  Future<Result<void>> remove(int id);
}
