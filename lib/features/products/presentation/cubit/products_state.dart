import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';

enum ProductsStatus { loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.loading,
    this.products = const [],
    this.topTags = const [],
    this.selectedTag,
    this.failure,
  });

  final ProductsStatus status;
  final List<Product> products;
  final List<String> topTags;
  final String? selectedTag;
  final Failure? failure;

  List<Product> get visibleProducts {
    final tag = selectedTag;
    if (tag == null) return products;
    return products.where((product) => product.hasTag(tag)).toList();
  }

  ProductsState withSelectedTag(String? tag) => ProductsState(
        status: status,
        products: products,
        topTags: topTags,
        selectedTag: tag,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, products, topTags, selectedTag, failure];
}
