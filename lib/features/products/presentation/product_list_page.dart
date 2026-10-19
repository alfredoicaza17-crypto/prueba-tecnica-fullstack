import 'package:flutter/material.dart';

import '../../favorites/domain/usecases/get_favorites.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../domain/entities/product.dart';
import 'product_list_controller.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({
    super.key,
    required this.controller,
    required this.getFavorites,
  });

  final ProductListController controller;
  final GetFavorites getFavorites;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TiendaApp'),
          Text(
            'Encuentra tus favoritos',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton.filledTonal(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    FavoritesPage(getFavorites: widget.getFavorites),
              ),
            ),
          ),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: widget.controller,
      builder: (_, _) => _body(),
    ),
  );

  Widget _body() {
    final controller = widget.controller;
    if (controller.status == ProductListStatus.loading) {
      return const _LoadingState();
    }
    if (controller.status == ProductListStatus.empty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No hay productos disponibles',
        message: 'Vuelve a intentarlo más tarde.',
      );
    }
    if (controller.status == ProductListStatus.offline ||
        controller.status == ProductListStatus.error) {
      final offline = controller.status == ProductListStatus.offline;
      return _MessageState(
        icon: offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        title: offline ? 'Sin conexión' : 'No pudimos cargar los productos',
        message: offline
            ? 'Revisa tu conexión a internet e inténtalo de nuevo.'
            : controller.message ?? 'Inténtalo de nuevo en unos minutos.',
        action: controller.load,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etiquetas populares',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.tags
                          .map(
                            (tag) => FilterChip(
                              avatar: const Icon(Icons.sell_outlined, size: 17),
                              label: Text(tag),
                              selected:
                                  controller.selectedTag?.toLowerCase() ==
                                  tag.toLowerCase(),
                              showCheckmark: false,
                              onSelected: (_) => controller.toggleTag(tag),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      controller.selectedTag == null
                          ? 'Productos'
                          : '“${controller.selectedTag}”',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (controller.products.isEmpty)
                      const _EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Sin resultados',
                        message: 'Prueba con otra etiqueta.',
                      )
                    else
                      ...controller.products.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProductCard(
                            product: product,
                            favorite: controller.isFavorite(product),
                            onFavorite: () => _toggleFavorite(product),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Product product) async {
    final wasFavorite = widget.controller.isFavorite(product);
    final failure = await widget.controller.toggleFavorite(product);
    if (!mounted) return;

    final text = failure != null
        ? failure.message
        : wasFavorite
        ? 'Se quitó de favoritos'
        : 'Se agregó a favoritos';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.favorite,
    required this.onFavorite,
  });
  final Product product;
  final bool favorite;
  final Future<void> Function() onFavorite;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    elevation: 0,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(url: product.thumbnailUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (product.tags.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: product.tags
                        .take(2)
                        .map((tag) => _TagPill(label: tag))
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: favorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            ),
            color: favorite ? Theme.of(context).colorScheme.error : null,
            onPressed: () => onFavorite(),
          ),
        ],
      ),
    ),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: 76,
      height: 76,
      child: url.isEmpty
          ? const ColoredBox(
              color: Color(0xffe9ecef),
              child: Icon(Icons.image_not_supported_outlined),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xffe9ecef),
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
    ),
  );
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Cargando productos...'),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: action,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}
