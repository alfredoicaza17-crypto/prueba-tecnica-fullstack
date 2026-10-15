import 'package:flutter/material.dart';

class ApiErrorView extends StatelessWidget {
  const ApiErrorView({
    super.key,
    required this.statusCode,
    required this.onRetry,
    this.isOffline = false,
  });

  final int? statusCode;
  final VoidCallback onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final message = isOffline
        ? 'Comprueba tu conexión e inténtalo de nuevo.'
        : 'Inténtalo de nuevo más tarde.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              isOffline
                  ? 'Sin conexión a internet.'
                  : statusCode == null
                  ? 'No se pudieron cargar los datos.'
                  : 'Error al cargar los datos (código $statusCode).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
