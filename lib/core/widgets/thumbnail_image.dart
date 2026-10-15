import 'package:flutter/material.dart';

class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.url, this.size = 56});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(
      Icons.image_not_supported_outlined,
      size: size * 0.5,
      color: Theme.of(context).colorScheme.outline,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? Center(child: placeholder)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(child: placeholder),
              ),
      ),
    );
  }
}
