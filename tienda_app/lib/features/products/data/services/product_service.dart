import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_dto.dart';
import '../models/products_response_dto.dart';

class ProductServiceException implements Exception {
  const ProductServiceException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => 'ProductServiceException($statusCode): $message';
}

class ProductService {
  ProductService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static final Uri _baseUri = Uri.https('dummyjson.com', '/products');

  final http.Client _client;
  final bool _ownsClient;

  Future<ProductsResponseDto> fetchProducts({int limit = 30, int skip = 0}) async {
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
    _ensureSuccess(response, uri);

    return ProductsResponseDto.fromJson(_decodeObject(response));
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
    _ensureSuccess(response, uri);

    return ProductDto.fromJson(_decodeObject(response));
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object from DummyJSON.');
    }
    return decoded;
  }

  void _ensureSuccess(http.Response response, Uri uri) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductServiceException(
        message: 'Request to $uri failed.',
        statusCode: response.statusCode,
      );
    }
  }
}
