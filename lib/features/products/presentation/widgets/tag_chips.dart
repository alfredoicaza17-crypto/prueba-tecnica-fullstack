import 'package:flutter/material.dart';

class TagChips extends StatelessWidget {
  const TagChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagPressed,
  });

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String> onTagPressed;

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
        itemBuilder: (context, index) {
          final tag = tags[index];
          return FilterChip(
            key: ValueKey('tag-$tag'),
            label: Text(tag),
            selected: tag == selectedTag,
            onSelected: (_) => onTagPressed(tag),
          );
        },
      ),
    );
  }
}
