import '../../../../core/error/result.dart';
import '../entities/favorite.dart';
import '../repositories/favorites_repository.dart';

/// Guarda un producto como favorito con la fecha actual.
class AddFavorite {
  AddFavorite(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FavoritesRepository _repository;
  final DateTime Function() _now;

  Future<Result<Favorite>> call({
    required int id,
    required String title,
    required double price,
    required String thumbnail,
    required List<String> tags,
  }) async {
    final favorite = Favorite(
      id: id,
      title: title,
      price: price,
      thumbnail: thumbnail,
      tags: List.unmodifiable(tags),
      addedAt: _now(),
    );
    return switch (await _repository.add(favorite)) {
      Ok() => Ok(favorite),
      Err(:final failure) => Err(failure),
    };
  }
}
