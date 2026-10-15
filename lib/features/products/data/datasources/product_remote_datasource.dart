import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(
    this._client, {
    Uri? endpoint,
    this.timeout = const Duration(seconds: 15),
  }) : _endpoint = endpoint ?? defaultEndpoint;

  static final Uri defaultEndpoint = Uri.parse(
    'https://dummyjson.com/products?limit=20&delay=2000',
  );

  final http.Client _client;
  final Uri _endpoint;
  final Duration timeout;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final http.Response response;
    try {
      response = await _client.get(_endpoint).timeout(timeout);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    }

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final products = (body as Map<String, dynamic>)['products'] as List;
      return products
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw ServerException(response.statusCode);
    } on TypeError {
      throw ServerException(response.statusCode);
    }
  }
}
