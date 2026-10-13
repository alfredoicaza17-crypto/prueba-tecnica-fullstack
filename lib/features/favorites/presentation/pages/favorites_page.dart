import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../domain/entities/favorite.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

/// RF-04 · Lista de favoritos guardados en SQLite (funciona sin conexión).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.initial ||
              (state.status == FavoritesStatus.loading &&
                  state.favorites.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FavoritesStatus.failure &&
              state.favorites.isEmpty) {
            return MessageView(
              icon: Icons.error_outline,
              title: 'No pudimos cargar tus favoritos.',
              actionLabel: 'Reintentar',
              onAction: context.read<FavoritesCubit>().load,
            );
          }
          if (state.favorites.isEmpty) {
            return const MessageView(
              icon: Icons.favorite_border,
              title: 'Aún no tienes favoritos.',
              message: 'Toca el corazón de un producto para guardarlo aquí.',
            );
          }
          return ListView.separated(
            itemCount: state.favorites.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _FavoriteTile(state.favorites[i]),
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile(this.favorite);

  final Favorite favorite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('favorite-${favorite.id}'),
      leading: ProductThumbnail(favorite.thumbnail),
      title: Text(favorite.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatPrice(favorite.price)),
          Text(
            'Agregado el ${formatDate(favorite.addedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (favorite.tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final tag in favorite.tags)
                  Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ],
      ),
      trailing: IconButton(
        tooltip: 'Quitar de favoritos',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<FavoritesCubit>().toggle(
          id: favorite.id,
          title: favorite.title,
          price: favorite.price,
          thumbnail: favorite.thumbnail,
          tags: favorite.tags,
        ),
      ),
    );
  }
}
