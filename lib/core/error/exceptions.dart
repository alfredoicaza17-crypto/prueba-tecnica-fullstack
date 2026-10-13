/// Excepciones de la capa de datos. Los repositorios las traducen a [Failure].
class NetworkException implements Exception {
  const NetworkException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'NetworkException($cause)';
}

class ServerException implements Exception {
  const ServerException({this.statusCode, this.cause});

  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, cause: $cause)';
}

class CacheException implements Exception {
  const CacheException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'CacheException($cause)';
}
