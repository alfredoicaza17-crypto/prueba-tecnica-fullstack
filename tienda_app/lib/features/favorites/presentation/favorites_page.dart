import 'package:flutter/material.dart';
import 'package:tienda_app/features/favorites/data/models/favorite.dart';
import 'package:tienda_app/features/favorites/data/repositories/favorites_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.repository});

  final FavoritesRepository repository;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Favorite> _favorites = const [];
  Object? _error;
  bool _isLoading = true;
  final Set<int> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favorites = await widget.repository.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Favorite favorite) async {
    if (_removingIds.contains(favorite.id)) return;
    setState(() => _removingIds.add(favorite.id));

    try {
      await widget.repository.removeFavorite(favorite.id);
      if (!mounted) return;
      setState(() {
        _favorites = _favorites
            .where((item) => item.id != favorite.id)
            .toList(growable: false);
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to remove favorite ${favorite.id}: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo quitar el favorito.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _removingIds.remove(favorite.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Cargando favoritos',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron cargar los favoritos.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadFavorites,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return const Center(child: Text('Todavía no tienes favoritos.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.network(
                      favorite.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('\$${favorite.price.toStringAsFixed(2)}'),
                      if (favorite.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final tag in favorite.tags)
                              Chip(
                                label: Text(tag),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removingIds.contains(favorite.id)
                      ? null
                      : () => _removeFavorite(favorite),
                  tooltip: 'Quitar de favoritos',
                  icon: _removingIds.contains(favorite.id)
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.favorite, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
