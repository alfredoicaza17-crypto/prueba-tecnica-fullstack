import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/top_tags.dart';
import '../../domain/usecases/get_products.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProducts, {this.popularTagsCount = 5})
      : super(const ProductsState());

  final GetProducts _getProducts;
  final int popularTagsCount;

  Future<void> load() async {
    emit(const ProductsState());
    try {
      final products = await _getProducts();
      final allTags = [for (final product in products) ...product.tags];
      emit(
        ProductsState(
          status: ProductsStatus.success,
          products: products,
          topTags: topTags(allTags, popularTagsCount),
        ),
      );
    } on Failure catch (failure) {
      emit(ProductsState(status: ProductsStatus.failure, failure: failure));
    } catch (_) {
      emit(
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(),
        ),
      );
    }
  }

  void toggleTag(String tag) {
    if (state.status != ProductsStatus.success) return;
    emit(state.withSelectedTag(state.selectedTag == tag ? null : tag));
  }
}
