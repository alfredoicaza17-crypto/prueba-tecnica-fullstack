
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../exceptions/product_exceptions.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl
    implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final url = Uri.parse(
        'https://dummyjson.com/products?limit=20&delay=2000',
      );

      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException(
          'El servidor respondió con HTTP ${response.statusCode}.',
        );
      }

      final data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'];

      return productsJson
          .map(
            (json) => ProductModel.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    } on SocketException catch (e) {
      // Esta clasificación es orientativa y depende
      // del mensaje que proporcione la plataforma.
      if (e.message.contains('Failed host lookup') ||
          e.message.contains('Name or service not known') ||
          e.message.contains('nodename nor servname')) {
        throw HostResolutionException();
      }

      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(
        'La solicitud tardó demasiado. Comprueba tu conexión.',
      );
    } on http.ClientException {
      throw NetworkException(
        'No se pudo establecer la conexión con el servidor.',
      );
    } on FormatException {
      throw ServerException(
        'El servidor devolvió una respuesta con formato inválido.',
      );
    } on ServerException {
      rethrow;
    } on HostResolutionException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {

      print('Error inesperado: $e');
      print(stackTrace);

      throw UnexpectedException();
    }
  }
}
