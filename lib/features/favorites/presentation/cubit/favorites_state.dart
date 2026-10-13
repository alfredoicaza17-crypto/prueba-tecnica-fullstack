import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.failure,
  });

  final FavoritesStatus status;

  /// Del más reciente al más antiguo.
  final List<Favorite> favorites;
  final Failure? failure;

  Set<int> get ids => {for (final f in favorites) f.id};

  bool isFavorite(int id) => favorites.any((f) => f.id == id);

  @override
  List<Object?> get props => [status, favorites, failure];
}
