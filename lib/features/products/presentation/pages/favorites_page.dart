import 'package:flutter/material.dart';

import '../bloc/favorite_bloc.dart';

class FavoritesPage extends StatefulWidget {
  final FavoriteBloc favoriteBloc;

  const FavoritesPage({super.key, required this.favoriteBloc});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    widget.favoriteBloc.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: AnimatedBuilder(
        animation: widget.favoriteBloc,
        builder: (context, _) {
          if (widget.favoriteBloc.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.favoriteBloc.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.favoriteBloc.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.favoriteBloc.loadFavorites,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (widget.favoriteBloc.favoriteProducts.isEmpty) {
            return const Center(child: Text('Todavía no tienes favoritos'));
          }

          return ListView.builder(
            itemCount: widget.favoriteBloc.favoriteProducts.length,
            itemBuilder: (context, index) {
              final favorite = widget.favoriteBloc.favoriteProducts[index];
              final product = favorite.product;
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(product.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}'),
                    if (product.tags.isNotEmpty) Text(product.tags.join(', ')),
                  ],
                ),
                trailing: IconButton(
                  tooltip: 'Quitar de favoritos',
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: widget.favoriteBloc.isPending(product.id)
                      ? null
                      : () async {
                          try {
                            await widget.favoriteBloc.toggleFavorite(product);
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
