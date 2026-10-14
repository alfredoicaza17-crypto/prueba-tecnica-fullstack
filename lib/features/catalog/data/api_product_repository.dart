import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../domain/product.dart';
import '../domain/product_repository.dart';

class ApiProductRepository implements ProductRepository {
  final http.Client client;
  final Duration timeout;
  ApiProductRepository(
    this.client, {
    this.timeout = const Duration(seconds: 15),
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await client
          .get(Uri.https('dummyjson.com', '/products', {'limit': '20'}))
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw const CatalogException(CatalogFailure.server);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = body['products'] as List<dynamic>;
      return rows.take(20).map((row) {
        final data = row as Map<String, dynamic>;
        return Product(
          id: data['id'] as int,
          title: data['title'] as String,
          price: (data['price'] as num).toDouble(),
          thumbnail: data['thumbnail'] as String,
          tags: (data['tags'] as List<dynamic>).cast<String>(),
        );
      }).toList();
    } on CatalogException {
      rethrow;
    } on SocketException {
      throw const CatalogException(CatalogFailure.offline);
    } on http.ClientException {
      throw const CatalogException(CatalogFailure.offline);
    } on TimeoutException {
      throw const CatalogException(CatalogFailure.offline);
    } on FormatException {
      throw const CatalogException(CatalogFailure.invalidResponse);
    } on TypeError {
      throw const CatalogException(CatalogFailure.invalidResponse);
    }
  }
}
