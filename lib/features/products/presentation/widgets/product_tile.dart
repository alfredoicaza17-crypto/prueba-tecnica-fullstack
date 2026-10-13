import 'package:flutter/material.dart';

import '../../../../core/formatters.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../domain/entities/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProductThumbnail(product.thumbnail),
      title: Text(product.title),
      subtitle: Text(formatPrice(product.price)),
      trailing: IconButton(
        key: ValueKey('fav-${product.id}'),
        tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Theme.of(context).colorScheme.error : null,
        ),
        onPressed: onToggleFavorite,
      ),
    );
  }
}
