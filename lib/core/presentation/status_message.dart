import 'package:flutter/material.dart';
import 'app_theme.dart';

class StatusMessage extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? retry;
  const StatusMessage({
    super.key,
    required this.message,
    this.title,
    required this.icon,
    this.retry,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.image,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.ink),
          ),
          const SizedBox(height: 24),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.6),
            ),
          ),
          if (retry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton(
                onPressed: retry,
                child: const Text('Reintentar'),
              ),
            ),
        ],
      ),
    ),
  );
}
