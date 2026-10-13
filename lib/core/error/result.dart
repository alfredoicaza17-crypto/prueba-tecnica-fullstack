import 'failures.dart';

/// Resultado de una operación de dominio: [Ok] con un valor o [Err] con un
/// [Failure]. Evita propagar excepciones fuera de la capa de datos.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
