import 'dart:convert';

import 'package:http/http.dart' as http;

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

class ProductApiUtils {
  static Map<String, dynamic> decodeObject(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object from DummyJSON.');
    }
    return decoded;
  }

  static void ensureSuccess(http.Response response, Uri uri) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductServiceException(
        message: 'Request to $uri failed.',
        statusCode: response.statusCode,
      );
    }
  }
}
