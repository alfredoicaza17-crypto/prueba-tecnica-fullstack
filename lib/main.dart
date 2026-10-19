import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'features/favorites/data/datasources/favorites_local_data_source.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/domain/usecases/remove_favorite.dart';
import 'features/favorites/domain/usecases/save_favorite.dart';
import 'features/products/data/datasources/products_remote_data_source.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/usecases/get_products.dart';
import 'features/products/presentation/product_list_controller.dart';
import 'features/products/presentation/product_list_page.dart';

void main() {
  final favoritesRepository = FavoritesRepositoryImpl(
    FavoritesLocalDataSourceImpl(),
  );
  final productsRepository = ProductsRepositoryImpl(
    ProductsRemoteDataSourceImpl(http.Client()),
  );
  final getFavorites = GetFavorites(favoritesRepository);
  runApp(
    TiendaApp(
      controller: ProductListController(
        GetProducts(productsRepository),
        getFavorites,
        SaveFavorite(favoritesRepository),
        RemoveFavorite(favoritesRepository),
      ),
      getFavorites: getFavorites,
    ),
  );
}

class TiendaApp extends StatelessWidget {
  const TiendaApp({
    super.key,
    required this.controller,
    required this.getFavorites,
  });
  final ProductListController controller;
  final GetFavorites getFavorites;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TiendaApp',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006a62)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfffbfdfc),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    ),
    home: ProductListPage(controller: controller, getFavorites: getFavorites),
  );
}
