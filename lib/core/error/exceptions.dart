class ServerException implements Exception {
  const ServerException([this.statusCode]);

  final int? statusCode;
}

class NetworkException implements Exception {
  const NetworkException();
}

class StorageException implements Exception {
  const StorageException();
}
