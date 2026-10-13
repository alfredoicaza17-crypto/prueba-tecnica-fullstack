import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required GetFavorites getFavorites,
    required AddFavorite addFavorite,
    required RemoveFavorite removeFavorite,
  }) : _getFavorites = getFavorites,
       _addFavorite = addFavorite,
       _removeFavorite = removeFavorite,
       super(const FavoritesState());

  final GetFavorites _getFavorites;
  final AddFavorite _addFavorite;
  final RemoveFavorite _removeFavorite;

  /// Ids con una escritura en curso: evita que un doble toque agregue y quite.
  final Set<int> _pending = {};

  Future<void> load() async {
    emit(
      FavoritesState(
        status: FavoritesStatus.loading,
        favorites: state.favorites,
      ),
    );
    await _reload();
  }

  /// Marca o desmarca el producto. Recibe datos planos para no acoplar esta
  /// feature con la entidad `Product`.
  Future<void> toggle({
    required int id,
    required String title,
    required double price,
    required String thumbnail,
    required List<String> tags,
  }) async {
    if (!_pending.add(id)) return;
    try {
      final result = state.isFavorite(id)
          ? await _removeFavorite(id)
          : await _addFavorite(
              id: id,
              title: title,
              price: price,
              thumbnail: thumbnail,
              tags: tags,
            );

      switch (result) {
        case Ok():
          await _reload();
        case Err(:final failure):
          _emitIfOpen(
            FavoritesState(
              status: FavoritesStatus.failure,
              favorites: state.favorites,
              failure: failure,
            ),
          );
      }
    } finally {
      _pending.remove(id);
    }
  }

  Future<void> _reload() async {
    switch (await _getFavorites()) {
      case Ok(value: final favorites):
        _emitIfOpen(
          FavoritesState(status: FavoritesStatus.success, favorites: favorites),
        );
      case Err(:final failure):
        _emitIfOpen(
          FavoritesState(
            status: FavoritesStatus.failure,
            favorites: state.favorites,
            failure: failure,
          ),
        );
    }
  }

  void _emitIfOpen(FavoritesState next) {
    if (!isClosed) emit(next);
  }
}
