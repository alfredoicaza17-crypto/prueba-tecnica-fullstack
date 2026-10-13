import 'package:flutter/material.dart';

class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail(this.url, {super.key, this.size = 56});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = SizedBox.square(
      dimension: size,
      child: const Icon(Icons.image_not_supported_outlined),
    );
    if (url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
