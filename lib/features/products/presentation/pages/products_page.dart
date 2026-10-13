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
import '../widgets/top_tags_bar.dart';

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
      body: BlocConsumer<ProductsCubit, ProductsState>(
        // Un refresh fallido mantiene la lista y avisa con un SnackBar.
        listenWhen: (prev, curr) =>
            curr.status == ProductsStatus.success &&
            curr.failure != null &&
            prev.failure != curr.failure,
        listener: (context, state) {
          final message = state.failure is NetworkFailure
              ? 'Sin conexión. Mostrando los últimos productos cargados.'
              : 'No se pudo actualizar el listado.';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          final cubit = context.read<ProductsCubit>();
          return switch (state.status) {
            ProductsStatus.initial || ProductsStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ProductsStatus.failure => _FailureView(
              failure: state.failure,
              onRetry: cubit.load,
            ),
            ProductsStatus.success when state.isEmpty => MessageView(
              icon: Icons.inventory_2_outlined,
              title: 'No hay productos para mostrar.',
              actionLabel: 'Recargar',
              onAction: cubit.load,
            ),
            ProductsStatus.success => _ProductsList(state: state),
          };
        },
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (failure) {
      NetworkFailure() => MessageView(
        icon: Icons.wifi_off,
        title: 'Sin conexión',
        message: 'Revisa tu conexión a internet e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      ),
      _ => MessageView(
        icon: Icons.error_outline,
        title: 'No pudimos cargar los productos',
        message: 'El servidor tuvo un problema. Inténtalo más tarde.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      ),
    };
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    final products = state.visibleProducts;
    final favorites = context.read<FavoritesCubit>();

    return Column(
      children: [
        TopTagsBar(
          tags: state.topTags,
          selected: state.selectedTag,
          onSelected: context.read<ProductsCubit>().toggleTag,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: context.read<ProductsCubit>().load,
            child: BlocSelector<FavoritesCubit, FavoritesState, Set<int>>(
              selector: (s) => s.ids,
              builder: (context, favoriteIds) => ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ProductTile(
                    key: ValueKey('product-${p.id}'),
                    product: p,
                    isFavorite: favoriteIds.contains(p.id),
                    onToggleFavorite: () => favorites.toggle(
                      id: p.id,
                      title: p.title,
                      price: p.price,
                      thumbnail: p.thumbnail,
                      tags: p.tags,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
