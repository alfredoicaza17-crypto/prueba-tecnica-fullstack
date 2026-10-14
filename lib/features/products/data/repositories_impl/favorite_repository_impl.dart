import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource localDataSource;

  FavoriteRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FavoriteProduct>> getFavorites() =>
      localDataSource.getFavorites();

  @override
  Future<bool> isFavorite(int productId) =>
      localDataSource.isFavorite(productId);

  @override
  Future<void> addFavorite(Product product) =>
      localDataSource.addFavorite(product);

  @override
  Future<void> removeFavorite(int productId) =>
      localDataSource.removeFavorite(productId);
}
