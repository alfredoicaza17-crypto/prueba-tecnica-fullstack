import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/top_tags.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProducts) : super(const ProductsState());

  static const topTagsCount = 5;

  final GetProducts _getProducts;

  /// Carga (o recarga) el listado.
  ///
  /// - Si todavía no hay productos, pasa por [ProductsStatus.loading] y un
  ///   error lleva a [ProductsStatus.failure] (pantalla con Reintentar).
  /// - Si ya hay productos (pull-to-refresh), los mantiene visibles mientras
  ///   recarga; un error solo se expone en [ProductsState.failure] para que la
  ///   UI lo avise sin perder la lista.
  Future<void> load() async {
    if (state.status == ProductsStatus.loading || state.isRefreshing) return;

    final hasData = state.products.isNotEmpty;
    emit(
      hasData
          ? state.copyWith(isRefreshing: true, failure: () => null)
          : state.copyWith(status: ProductsStatus.loading, failure: () => null),
    );

    switch (await _getProducts()) {
      case Ok(value: final products):
        final tags = [for (final p in products) ...p.tags];
        final top = topTags(tags, topTagsCount);
        final selected = state.selectedTag;
        emit(
          ProductsState(
            status: ProductsStatus.success,
            products: products,
            topTags: top,
            // Conserva el filtro si la etiqueta sigue entre las populares.
            selectedTag: top.contains(selected) ? selected : null,
          ),
        );
      case Err(:final failure):
        emit(
          hasData
              ? state.copyWith(isRefreshing: false, failure: () => failure)
              : state.copyWith(
                  status: ProductsStatus.failure,
                  failure: () => failure,
                ),
        );
    }
  }

  /// Selecciona [tag]; si ya estaba seleccionada, quita el filtro.
  void toggleTag(String tag) {
    final next = state.selectedTag == tag ? null : tag;
    emit(state.copyWith(selectedTag: () => next));
  }
}
