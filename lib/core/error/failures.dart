sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No tienes conexión a internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'No se pudieron actualizar los favoritos.',
  ]);
}
