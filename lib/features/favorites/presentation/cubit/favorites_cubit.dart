import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._getFavorites, this._toggleFavorite, this._removeFavorite)
      : super(const FavoritesState());

  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;
  final RemoveFavorite _removeFavorite;

  Future<void> load() async {
    try {
      final favorites = await _getFavorites();
      emit(FavoritesState(status: FavoritesStatus.ready, favorites: favorites));
    } catch (_) {
      emit(
        FavoritesState(
          status: FavoritesStatus.failure,
          favorites: state.favorites,
        ),
      );
    }
  }

  Future<void> toggle(Product product) => _mutate(() => _toggleFavorite(product));

  Future<void> remove(int productId) => _mutate(() => _removeFavorite(productId));

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      emit(
        FavoritesState(
          status: FavoritesStatus.failure,
          favorites: state.favorites,
        ),
      );
      return;
    }
    await load();
  }
}
