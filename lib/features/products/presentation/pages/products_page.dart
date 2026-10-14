import 'package:flutter/material.dart';

import '../bloc/favorite_bloc.dart';
import '../bloc/product_bloc.dart';
import 'favorites_page.dart';

class ProductsPage extends StatelessWidget {
  final ProductBloc provider;
  final FavoriteBloc favoriteProvider;

  const ProductsPage({
    super.key,
    required this.provider,
    required this.favoriteProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TiendaApp - Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FavoritesPage(favoriteBloc: favoriteProvider),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando productos...'),
                ],
              ),
            );
          }

          if (provider.isNetworkError) {
            return _StatusMessage(
              icon: Icons.wifi_off,
              color: Colors.orange,
              title: 'Sin conexión a internet',
              message:
                  provider.errorMessage ??
                  'Verifica tu red e inténtalo nuevamente.',
              onRetry: provider.fetchProducts,
            );
          }

          if (provider.errorMessage != null) {
            return _StatusMessage(
              icon: Icons.error_outline,
              color: Colors.red,
              title: '¡Vaya! Algo salió mal',
              message: provider.errorMessage!,
              onRetry: provider.fetchProducts,
            );
          }

          if (provider.products.isEmpty) {
            return _StatusMessage(
              icon: Icons.inbox_outlined,
              color: Colors.grey,
              title: 'No hay productos disponibles',
              onRetry: provider.fetchProducts,
              retryLabel: 'Actualizar',
            );
          }

          final products = provider.filteredProducts;
          return Column(
            children: [
              if (provider.availableTopTags.isNotEmpty)
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: provider.availableTopTags.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = provider.availableTopTags[index];
                      return ChoiceChip(
                        label: Text(tag),
                        selected: provider.selectedTagFilter == tag,
                        onSelected: (_) => provider.toggleTagFilter(tag),
                      );
                    },
                  ),
                ),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text('No hay productos con esta etiqueta'),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return AnimatedBuilder(
                            animation: favoriteProvider,
                            builder: (context, _) => ListTile(
                              leading: Image.network(
                                product.thumbnail,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                              title: Text(product.title),
                              subtitle: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                tooltip: favoriteProvider.isFavorite(product.id)
                                    ? 'Quitar de favoritos'
                                    : 'Agregar a favoritos',
                                icon: Icon(
                                  favoriteProvider.isFavorite(product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favoriteProvider.isFavorite(product.id)
                                      ? Colors.red
                                      : null,
                                ),
                                onPressed:
                                    favoriteProvider.isPending(product.id)
                                    ? null
                                    : () async {
                                        try {
                                          await favoriteProvider.toggleFavorite(
                                            product,
                                          );
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(error.toString()),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? message;
  final Future<void> Function() onRetry;
  final String retryLabel;

  const _StatusMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.onRetry,
    this.message,
    this.retryLabel = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
