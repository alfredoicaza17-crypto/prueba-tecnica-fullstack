import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/catalog/domain/product.dart';
import '../../features/favorites/presentation/favorites_controller.dart';
import 'app_theme.dart';
import 'catalog_skeleton.dart';
import 'tag_label.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final FavoritesController favorites;
  final bool showTags;
  final bool horizontal;
  const ProductTile({
    super.key,
    required this.product,
    required this.favorites,
    this.showTags = false,
    this.horizontal = false,
  });

  Widget _image(BuildContext context) => Image.network(
    product.thumbnail,
    fit: BoxFit.contain,
    errorBuilder: (_, error, stack) => const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.muted,
        size: 30,
      ),
    ),
    frameBuilder: (_, child, frame, synchronous) => AnimatedOpacity(
      opacity: synchronous || frame != null ? 1 : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      child: child,
    ),
    loadingBuilder: (_, child, progress) => progress == null
        ? child
        : const Shimmer(
            child: SkeletonBlock(height: double.infinity, radius: 12),
          ),
  );

  Widget _favorite(BuildContext context) {
    final selected = favorites.contains(product.id);
    final pending = favorites.pending.contains(product.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line),
      ),
      child: IconButton(
        key: ValueKey('favorite-${product.id}'),
        tooltip: selected ? 'Quitar de favoritos' : 'Agregar a favoritos',
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        onPressed: favorites.loading || favorites.error != null || pending
            ? null
            : () async {
                final success = await favorites.toggle(product);
                if (success) HapticFeedback.selectionClick();
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudo actualizar el favorito. Intenta de nuevo.',
                      ),
                    ),
                  );
                }
              },
        icon: pending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  selected
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(selected),
                  size: 21,
                  color: selected ? AppColors.accent : AppColors.ink,
                ),
              ),
      ),
    );
  }

  Widget _details(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: horizontal
            ? null
            : MediaQuery.textScalerOf(context).scale(15) * 2.7,
        child: Tooltip(
          message: product.title,
          child: Text(
            product.title,
            maxLines: horizontal ? null : 2,
            overflow: horizontal ? null : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'USD ${product.price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      if (showTags)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: product.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.image,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tagLabel(tag),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: horizontal
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 86,
                    height: 108,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.image,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image(context),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _details(context)),
                  const SizedBox(width: 6),
                  _favorite(context),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: AppColors.image,
                          padding: const EdgeInsets.fromLTRB(18, 30, 18, 12),
                          child: _image(context),
                        ),
                      ),
                      Positioned(top: 10, right: 10, child: _favorite(context)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: _details(context),
                ),
              ],
            ),
    ),
  );
}
