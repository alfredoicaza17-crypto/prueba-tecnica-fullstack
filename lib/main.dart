import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'features/products/data/datasources/favorite_local_data_source.dart';
import 'features/products/data/database/app_database.dart';
import 'features/products/data/repositories_impl/favorite_repository_impl.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/repositories_impl/product_repository_impl.dart';
import 'features/products/domain/usecases/get_products_usecase.dart';
import 'features/products/presentation/bloc/favorite_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/pages/products_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = http.Client();
  final remoteDataSource = ProductRemoteDataSourceImpl(client: client);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);
  final getProductsUseCase = GetProductsUseCase(repository);
  final productProvider = ProductBloc(getProductsUseCase: getProductsUseCase);
  final favoriteDataSource = FavoriteLocalDataSource(
    AppDatabase.instance.database,
  );
  final favoriteRepository = FavoriteRepositoryImpl(
    localDataSource: favoriteDataSource,
  );
  final favoriteProvider = FavoriteBloc(repository: favoriteRepository);

  productProvider.fetchProducts();
  favoriteProvider.loadFavorites();

  runApp(
    TiendaApp(
      productProvider: productProvider,
      favoriteProvider: favoriteProvider,
    ),
  );
}

class TiendaApp extends StatelessWidget {
  final ProductBloc productProvider;
  final FavoriteBloc favoriteProvider;

  const TiendaApp({
    super.key,
    required this.productProvider,
    required this.favoriteProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TiendaApp',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductsPage(
        provider: productProvider,
        favoriteProvider: favoriteProvider,
      ),
    );
  }
}
