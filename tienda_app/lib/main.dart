import 'package:flutter/material.dart';

import 'features/products/presentation/products_page.dart';
import 'features/products/data/services/product_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.productService});

  final ProductService? productService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: ProductsPage(service: productService),
    );
  }
}
