import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/thumbnail_image.dart';
import '../../domain/entities/favorite.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          switch (state.status) {
            case FavoritesStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case FavoritesStatus.failure:
              return MessageView(
                icon: Icons.error_outline,
                message: 'No se pudieron cargar tus favoritos.',
                actionLabel: 'Reintentar',
                onAction: () => context.read<FavoritesCubit>().load(),
              );
            case FavoritesStatus.ready:
              if (state.favorites.isEmpty) {
                return const MessageView(
                  icon: Icons.favorite_border,
                  message: 'Aún no tienes productos favoritos.',
                );
              }
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) =>
                    _FavoriteTile(favorite: state.favorites[index]),
              );
          }
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.favorite});

  final Favorite favorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      key: ValueKey('favorite-tile-${favorite.id}'),
      leading: ThumbnailImage(url: favorite.thumbnail),
      title: Text(
        favorite.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatPrice(favorite.price)),
          if (favorite.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in favorite.tags)
                    Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      labelStyle: theme.textTheme.labelSmall,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
        ],
      ),
      trailing: IconButton(
        key: ValueKey('remove-favorite-${favorite.id}'),
        tooltip: 'Quitar de favoritos',
        icon: Icon(Icons.favorite, color: theme.colorScheme.error),
        onPressed: () => context.read<FavoritesCubit>().remove(favorite.id),
      ),
    );
  }
}
