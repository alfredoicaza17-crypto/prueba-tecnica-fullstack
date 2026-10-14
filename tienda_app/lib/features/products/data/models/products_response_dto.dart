import 'product_dto.dart';

class ProductsResponseDto {
  const ProductsResponseDto({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductDto> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductsResponseDto.fromJson(Map<String, dynamic> json) {
    return ProductsResponseDto(
      products: (json['products'] as List<dynamic>)
          .map(
            (product) =>
                ProductDto.fromJson(Map<String, dynamic>.from(product as Map)),
          )
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => product.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
