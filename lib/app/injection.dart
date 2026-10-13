import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/favorites/domain/usecases/add_favorite.dart';
import '../features/favorites/domain/usecases/get_favorites.dart';
import '../features/favorites/domain/usecases/remove_favorite.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/products/data/datasources/product_remote_data_source.dart';
import '../features/products/data/repositories/product_repository_impl.dart';
import '../features/products/domain/usecases/get_products.dart';
import '../features/products/presentation/cubit/products_cubit.dart';

/// Composition root: el único lugar que conoce las implementaciones concretas.
class AppDependencies {
  AppDependencies({required http.Client client, required Database database})
    : _client = client,
      _database = database;

  final http.Client _client;
  final Database _database;

  ProductsCubit productsCubit() => ProductsCubit(
    GetProducts(
      ProductRepositoryImpl(ProductRemoteDataSourceImpl(client: _client)),
    ),
  );

  FavoritesCubit favoritesCubit() {
    final repository = FavoritesRepositoryImpl(
      FavoritesLocalDataSourceImpl(_database),
    );
    return FavoritesCubit(
      getFavorites: GetFavorites(repository),
      addFavorite: AddFavorite(repository),
      removeFavorite: RemoveFavorite(repository),
    );
  }
}
