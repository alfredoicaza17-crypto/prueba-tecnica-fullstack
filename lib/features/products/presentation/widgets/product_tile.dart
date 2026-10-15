import 'package:flutter/material.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/widgets/thumbnail_image.dart';
import '../../domain/entities/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ThumbnailImage(url: product.thumbnail),
      title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatPrice(product.price)),
      trailing: IconButton(
        key: ValueKey('favorite-${product.id}'),
        tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        color: isFavorite ? Theme.of(context).colorScheme.error : null,
        onPressed: onFavoritePressed,
      ),
    );
  }
}
