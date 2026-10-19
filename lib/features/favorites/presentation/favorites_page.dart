import 'package:flutter/material.dart';

import '../domain/entities/favorite_product.dart';
import '../domain/usecases/get_favorites.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.getFavorites});
  final GetFavorites getFavorites;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<FavoriteProduct>?> _future;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = widget.getFavorites().then((result) {
      _error = result.failure?.message;
      return result.favorites;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favoritos')),
    body: FutureBuilder<List<FavoriteProduct>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
          return _FavoriteEmpty(
            icon: Icons.error_outline_rounded,
            title: 'No se pudieron cargar los favoritos',
            message: _error!,
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const _FavoriteEmpty(
            icon: Icons.favorite_border_rounded,
            title: 'Aún no tienes favoritos',
            message: 'Guarda productos para encontrarlos rápidamente aquí.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...items.map(
                      (favorite) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FavoriteCard(favorite: favorite),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.favorite});
  final FavoriteProduct favorite;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  favorite.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${favorite.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (favorite.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: favorite.tags
                  .map(
                    (tag) => Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(tag),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    ),
  );
}

class _FavoriteEmpty extends StatelessWidget {
  const _FavoriteEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
