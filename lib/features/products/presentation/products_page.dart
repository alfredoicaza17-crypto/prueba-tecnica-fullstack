import 'package:flutter/material.dart';

import '../../favorites/domain/favorites.dart';
import '../../favorites/presentation/favorites_page.dart';
import 'products_controller.dart';

class ProductsPage extends StatelessWidget {
  final ProductsController controller;
  final FavoritesRepository favorites;

  const ProductsPage({super.key, required this.controller, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TiendaApp'),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FavoritesPage(repository: favorites),
            )),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => _body(),
      ),
    );
  }

  Widget _body() {
    switch (controller.status) {
      case ProductsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ProductsStatus.error:
        return _Message(
          text: 'Ocurrió un error en el servidor. Intenta de nuevo.',
          onRetry: controller.load,
        );
      case ProductsStatus.offline:
        return _Message(
          text: 'Sin conexión a internet. Revisa tu red.',
          onRetry: controller.load,
        );
      case ProductsStatus.loaded:
        final products = controller.products;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final tag in controller.popularTags)
                    FilterChip(
                      label: Text(tag),
                      selected: controller.selectedTag == tag,
                      onSelected: (_) => controller.toggleTag(tag),
                    ),
                ],
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No hay productos'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        final p = products[i];
                        final isFav = controller.favoriteIds.contains(p.id);
                        return ListTile(
                          leading: Image.network(
                            p.thumbnail,
                            width: 56,
                            height: 56,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title: Text(p.title),
                          subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                            color: isFav ? Colors.red : null,
                            onPressed: () => controller.toggleFavorite(p),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
    }
  }
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _Message({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
