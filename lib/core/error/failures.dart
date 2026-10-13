import 'package:equatable/equatable.dart';

/// Errores de dominio que la presentación sabe mostrar.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// No hay conexión a internet (o no se pudo alcanzar el servidor).
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}

/// El servidor respondió con error o con datos inválidos.
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'El servidor no respondió correctamente.',
  ]);
}

/// Error al leer o escribir en la base de datos local.
final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'No se pudo acceder a los datos locales.',
  ]);
}
