import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  /// Lanza [NetworkException] si no hay conexión y [ServerException] si el
  /// servidor responde con error o con un cuerpo inválido.
  Future<List<ProductModel>> getProducts({required int limit});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({
    required http.Client client,
    this.baseUrl = 'https://dummyjson.com',
    this.timeout = const Duration(seconds: 15),
  }) : _client = client;

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  @override
  Future<List<ProductModel>> getProducts({required int limit}) async {
    final uri = Uri.parse('$baseUrl/products?limit=$limit');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on SocketException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      // En dart:io, http envuelve los SocketException en ClientException.
      throw NetworkException(e);
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    }

    if (response.statusCode != 200) {
      throw ServerException(statusCode: response.statusCode);
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['products'] as List<dynamic>;
      return items
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException catch (e) {
      throw ServerException(statusCode: response.statusCode, cause: e);
    } on TypeError catch (e) {
      throw ServerException(statusCode: response.statusCode, cause: e);
    }
  }
}
