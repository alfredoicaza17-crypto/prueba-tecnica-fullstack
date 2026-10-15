import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_tile.dart';
import '../widgets/tag_chips.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TiendaApp'),
        actions: [
          IconButton(
            key: const ValueKey('open-favorites'),
            tooltip: 'Favoritos',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FavoritesPage()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProductsStatus.failure:
              return _FailureView(
                failure: state.failure,
                onRetry: () => context.read<ProductsCubit>().load(),
              );
            case ProductsStatus.success:
              if (state.products.isEmpty) {
                return const MessageView(
                  icon: Icons.inventory_2_outlined,
                  message: 'No hay productos disponibles.',
                );
              }
              return _ProductsList(state: state);
          }
        },
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    final products = state.visibleProducts;

    return Column(
      children: [
        TagChips(
          tags: state.topTags,
          selectedTag: state.selectedTag,
          onTagPressed: context.read<ProductsCubit>().toggleTag,
        ),
        Expanded(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoritesState) {
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductTile(
                    product: product,
                    isFavorite: favoritesState.isFavorite(product.id),
                    onFavoritePressed: () =>
                        context.read<FavoritesCubit>().toggle(product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isNetwork = failure is NetworkFailure;

    return MessageView(
      icon: isNetwork ? Icons.wifi_off : Icons.cloud_off,
      message: isNetwork
          ? 'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.'
          : 'El servidor tuvo un problema. Inténtalo de nuevo en unos minutos.',
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }
}
