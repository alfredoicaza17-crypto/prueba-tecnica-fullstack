import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'core/database/app_database.dart';
import 'features/favorites/data/datasources/favorite_local_datasource.dart';
import 'features/favorites/data/repositories/favorite_repository_impl.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/domain/usecases/remove_favorite.dart';
import 'features/favorites/domain/usecases/toggle_favorite.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/usecases/get_products.dart';
import 'features/products/presentation/cubit/products_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await openAppDatabase();

  final productRepository = ProductRepositoryImpl(
    ProductRemoteDataSourceImpl(http.Client()),
  );
  final favoriteRepository = FavoriteRepositoryImpl(
    FavoriteLocalDataSourceImpl(database),
  );

  final productsCubit = ProductsCubit(GetProducts(productRepository))..load();
  final favoritesCubit = FavoritesCubit(
    GetFavorites(favoriteRepository),
    ToggleFavorite(favoriteRepository),
    RemoveFavorite(favoriteRepository),
  )..load();

  runApp(
    TiendaApp(productsCubit: productsCubit, favoritesCubit: favoritesCubit),
  );
}
