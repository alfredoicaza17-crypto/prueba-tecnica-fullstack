class ServerException implements Exception {
  const ServerException([
    this.message = 'El servidor no pudo procesar la solicitud.',
  ]);

  final String message;
}

class NetworkException implements Exception {
  const NetworkException();
}

class CacheException implements Exception {
  const CacheException([
    this.message = 'No se pudieron guardar los favoritos.',
  ]);

  final String message;
}
