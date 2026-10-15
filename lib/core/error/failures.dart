import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure();

  @override
  List<Object?> get props => const [];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class ServerFailure extends Failure {
  const ServerFailure();
}

class StorageFailure extends Failure {
  const StorageFailure();
}
