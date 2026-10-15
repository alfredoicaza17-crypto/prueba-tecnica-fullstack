import 'package:http/http.dart' as http;

import '../models/product_dto.dart';
import '../models/products_response_dto.dart';
import '../utils/product_api_utils.dart';

class ProductService {
  ProductService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static final Uri _baseUri = Uri.https('dummyjson.com', '/products');

  final http.Client _client;
  final bool _ownsClient;

  Future<ProductsResponseDto> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero.');
    }
    if (skip < 0) {
      throw ArgumentError.value(skip, 'skip', 'Must not be negative.');
    }

    final uri = _baseUri.replace(
      queryParameters: {'limit': '$limit', 'skip': '$skip'},
    );
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    ProductApiUtils.ensureSuccess(response, uri);

    return ProductsResponseDto.fromJson(ProductApiUtils.decodeObject(response));
  }

  Future<ProductDto> fetchProductById(int id) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Must be greater than zero.');
    }

    final uri = _baseUri.resolve('/products/$id');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    ProductApiUtils.ensureSuccess(response, uri);

    return ProductDto.fromJson(ProductApiUtils.decodeObject(response));
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
