import 'package:flutter/material.dart';

class ProductsLayout extends StatelessWidget {
  const ProductsLayout({
    super.key,
    required this.body,
    required this.onRefresh,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    this.isRefreshing = false,
  });

  final Widget body;
  final VoidCallback onRefresh;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ismael Moron - Tienda App'),
        actions: [
          IconButton(
            onPressed: isRefreshing ? null : onRefresh,
            tooltip: 'Actualizar productos',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: totalPages > 1
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: isRefreshing || currentPage == 0
                          ? null
                          : onPreviousPage,
                      tooltip: 'Página anterior',
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Página ${currentPage + 1} de $totalPages'),
                    IconButton(
                      onPressed: isRefreshing || currentPage >= totalPages - 1
                          ? null
                          : onNextPage,
                      tooltip: 'Página siguiente',
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
