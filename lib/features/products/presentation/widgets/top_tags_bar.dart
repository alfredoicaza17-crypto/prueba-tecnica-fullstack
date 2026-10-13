import 'package:flutter/material.dart';

/// RF-03 · Chips con las etiquetas más frecuentes.
class TopTagsBar extends StatelessWidget {
  const TopTagsBar({
    super.key,
    required this.tags,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tags;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tag = tags[i];
          return FilterChip(
            key: ValueKey('tag-$tag'),
            label: Text(tag),
            selected: tag == selected,
            onSelected: (_) => onSelected(tag),
          );
        },
      ),
    );
  }
}
