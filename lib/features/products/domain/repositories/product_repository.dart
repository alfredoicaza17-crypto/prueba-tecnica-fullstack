import '../../../../core/error/result.dart';
import '../entities/product.dart';

abstract interface class ProductRepository {
  Future<Result<List<Product>>> getProducts({required int limit});
}
