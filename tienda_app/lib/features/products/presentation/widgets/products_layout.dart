import 'package:flutter/material.dart';

class ProductsLayout extends StatelessWidget {
  const ProductsLayout({
    super.key,
    required this.body,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  final Widget body;
  final VoidCallback onRefresh;
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
    );
  }
}
