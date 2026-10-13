import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';

enum ProductsStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.topTags = const [],
    this.selectedTag,
    this.isRefreshing = false,
    this.failure,
  });

  final ProductsStatus status;
  final List<Product> products;
  final List<String> topTags;
  final String? selectedTag;

  /// Recargando con la lista ya visible (pull-to-refresh).
  final bool isRefreshing;

  /// Con [ProductsStatus.failure], el error que impidió la carga inicial.
  /// Con [ProductsStatus.success], el error de un refresh fallido.
  final Failure? failure;

  bool get isEmpty => status == ProductsStatus.success && products.isEmpty;

  /// Productos a mostrar según la etiqueta seleccionada (RF-03).
  List<Product> get visibleProducts {
    final tag = selectedTag;
    if (tag == null) return products;
    return products.where((p) => p.hasTag(tag)).toList(growable: false);
  }

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<String>? topTags,
    String? Function()? selectedTag,
    bool? isRefreshing,
    Failure? Function()? failure,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      topTags: topTags ?? this.topTags,
      selectedTag: selectedTag != null ? selectedTag() : this.selectedTag,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    topTags,
    selectedTag,
    isRefreshing,
    failure,
  ];
}
