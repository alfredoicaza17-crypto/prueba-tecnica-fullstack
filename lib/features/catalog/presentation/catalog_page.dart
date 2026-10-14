import 'package:flutter/material.dart';
import '../../../core/presentation/app_theme.dart';
import '../../../core/presentation/responsive_content.dart';
import '../../../core/presentation/catalog_skeleton.dart';
import '../../../core/presentation/entrance.dart';
import '../../../core/presentation/tag_label.dart';
import '../../../core/presentation/product_tile.dart';
import '../../../core/presentation/status_message.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../favorites/presentation/favorites_page.dart';
import 'catalog_controller.dart';

class CatalogPage extends StatelessWidget {
  final CatalogController catalog;
  final FavoritesController favorites;
  const CatalogPage({
    super.key,
    required this.catalog,
    required this.favorites,
  });

  Widget _chip(String label, bool selected, VoidCallback onTap) => FilterChip(
    label: Text(
      tagLabel(label),
      style: TextStyle(color: selected ? Colors.white : AppColors.ink),
    ),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: AppColors.ink,
    side: BorderSide(color: selected ? AppColors.ink : AppColors.line),
  );

  Widget _catalog(BuildContext context) {
    final products = catalog.visibleProducts;
    final wideText = MediaQuery.textScalerOf(context).scale(14) > 18;
    final useList = MediaQuery.sizeOf(context).width < 360 || wideText;
    return CustomScrollView(
      key: ValueKey(catalog.selectedTag),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UNA SELECCIÓN PARA TI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Encuentra tu\npróximo favorito.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Explora productos. Guarda lo que te gusta.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'ETIQUETAS POPULARES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip('Todas', catalog.selectedTag == null, () {
                    if (catalog.selectedTag != null) {
                      catalog.selectTag(catalog.selectedTag!);
                    }
                  }),
                ),
                ...catalog.popularTags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(
                      tag,
                      catalog.selectedTag == tag,
                      () => catalog.selectTag(tag),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    catalog.selectedTag == null ? 'Catálogo' : 'Selección',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${products.length} ${products.length == 1 ? 'producto' : 'productos'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: StatusMessage(
              message: 'No hay productos con esta etiqueta.',
              icon: Icons.filter_alt_off,
            ),
          )
        else if (useList)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => Entrance(
                key: ValueKey(products[i].id),
                child: ProductTile(
                  product: products[i],
                  favorites: favorites,
                  horizontal: true,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisExtent: 280,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (_, i) => Entrance(
                key: ValueKey(products[i].id),
                child: ProductTile(product: products[i], favorites: favorites),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 24,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_mall_outlined, size: 22),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'TiendaApp',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AnimatedBuilder(
            animation: favorites,
            builder: (_, _) => IconButton(
              tooltip: 'Favoritos',
              icon: Badge(
                isLabelVisible: favorites.items.isNotEmpty,
                label: Text('${favorites.items.length}'),
                backgroundColor: AppColors.ink,
                child: const Icon(Icons.favorite_border_rounded, size: 23),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FavoritesPage(controller: favorites),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        child: AnimatedBuilder(
          animation: Listenable.merge([catalog, favorites]),
          builder: (context, _) {
            final Widget content;
            switch (catalog.status) {
              case CatalogStatus.loading:
                content = const CatalogSkeleton();
              case CatalogStatus.offline:
                content = StatusMessage(
                  title: 'Tus favoritos siguen contigo',
                  message:
                      'Sin conexión. Revisa tu red e intenta de nuevo. Tus favoritos siguen disponibles.',
                  icon: Icons.wifi_off_rounded,
                  retry: catalog.load,
                );
              case CatalogStatus.error:
                content = StatusMessage(
                  title: 'Intentémoslo de nuevo',
                  message:
                      'No pudimos cargar los productos del servidor. Intenta de nuevo.',
                  icon: Icons.cloud_off_outlined,
                  retry: catalog.load,
                );
              case CatalogStatus.empty:
                content = const StatusMessage(
                  title: 'El catálogo está vacío',
                  message: 'No hay productos disponibles.',
                  icon: Icons.inventory_2_outlined,
                );
              case CatalogStatus.ready:
                content = _catalog(context);
            }
            return Column(
              children: [
                if (favorites.error != null)
                  MaterialBanner(
                    content: Text(favorites.error!),
                    actions: [
                      TextButton(
                        onPressed: favorites.load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey('${catalog.status}:${catalog.selectedTag}'),
                      child: content,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
