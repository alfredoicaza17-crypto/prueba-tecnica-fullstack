import 'package:flutter/material.dart';
import '../../../core/presentation/app_theme.dart';
import '../../../core/presentation/responsive_content.dart';
import '../../../core/presentation/catalog_skeleton.dart';
import '../../../core/presentation/entrance.dart';
import '../../../core/presentation/product_tile.dart';
import '../../../core/presentation/status_message.dart';
import 'favorites_controller.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesController controller;
  const FavoritesPage({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Favoritos',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        maxWidth: 760,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.loading) {
              return const CatalogSkeleton(horizontal: true);
            }
            if (controller.error != null) {
              return StatusMessage(
                message: controller.error!,
                icon: Icons.storage,
                retry: controller.load,
              );
            }
            if (controller.items.isEmpty) {
              return const StatusMessage(
                title: 'Tu colección empieza aquí',
                message:
                    'Todavía no tienes favoritos. Agrégalos desde el catálogo.',
                icon: Icons.favorite_border,
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GUARDADOS POR TI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tus favoritos,\nsiempre contigo.',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${controller.items.length} ${controller.items.length == 1 ? 'guardado' : 'guardados'} · Más recientes primero',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.offline_pin_outlined,
                              size: 15,
                              color: AppColors.muted,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Disponibles sin conexión',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: controller.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => Entrance(
                      key: ValueKey(controller.items[index].product.id),
                      child: ProductTile(
                        product: controller.items[index].product,
                        favorites: controller,
                        showTags: true,
                        horizontal: true,
                      ),
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
