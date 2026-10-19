import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract interface class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._client);

  final http.Client _client;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('https://dummyjson.com/products?limit=20&delay=2000'),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'El servidor respondió con código ${response.statusCode}.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final products = body['products'];
      if (products is! List) {
        throw const ServerException('La respuesta del servidor no es válida.');
      }
      return products
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(growable: false);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException {
      throw const ServerException('La respuesta del servidor no es válida.');
    }
  }
}
