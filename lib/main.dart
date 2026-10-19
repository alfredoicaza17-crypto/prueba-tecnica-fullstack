import 'package:flutter/material.dart';

import 'features/favorites/data/favorites_repository_impl.dart';
import 'features/products/data/product_repository_impl.dart';
import 'features/products/presentation/products_controller.dart';
import 'features/products/presentation/products_page.dart';

void main() {
  final favorites = FavoritesRepositoryImpl();
  final controller = ProductsController(ProductRepositoryImpl(), favorites)..load();

  runApp(MaterialApp(
    title: 'TiendaApp',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: ProductsPage(controller: controller, favorites: favorites),
  ));
}
