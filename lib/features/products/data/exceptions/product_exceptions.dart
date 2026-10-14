
class NetworkException implements Exception {
  final String message;

  NetworkException([
    this.message = 'Verifica tu conexión a internet.',
  ]);

  @override
  String toString() => message;
}

class HostResolutionException implements Exception {
  final String message;

  HostResolutionException([
    this.message = 'No se pudo resolver el dominio del servidor.',
  ]);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;

  ServerException([
    this.message = 'El servidor no pudo procesar la solicitud.',
  ]);

  @override
  String toString() => message;
}

class UnexpectedException implements Exception {
  final String message;

  UnexpectedException([
    this.message = 'Ocurrió un error inesperado.',
  ]);

  @override
  String toString() => message;
}
