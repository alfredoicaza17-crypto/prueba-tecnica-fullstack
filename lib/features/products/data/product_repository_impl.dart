import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final http.Client _client;

  ProductRepositoryImpl([http.Client? client]) : _client = client ?? http.Client();

  @override
  Future<List<Product>> getProducts({int limit = 20}) async {
    try {
      final response = await _client
          .get(Uri.parse('https://dummyjson.com/products?limit=$limit'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw ServerException();

      final list = jsonDecode(response.body)['products'] as List;
      return list.map((j) {
        return Product(
          id: j['id'] as int,
          title: j['title'] as String,
          price: (j['price'] as num).toDouble(),
          thumbnail: j['thumbnail'] as String,
          tags: List<String>.from(j['tags'] ?? const []),
        );
      }).toList();
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException();
    }
  }
}
