import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite.dart';

enum FavoritesStatus { loading, ready, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.loading,
    this.favorites = const [],
  });

  final FavoritesStatus status;
  final List<Favorite> favorites;

  bool isFavorite(int productId) =>
      favorites.any((favorite) => favorite.id == productId);

  @override
  List<Object?> get props => [status, favorites];
}
