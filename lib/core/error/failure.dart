import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error'});
}

class ServerFailure extends Failure {
  final String? code;

  const ServerFailure({super.message = 'Server error', this.code});

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = 'Authentication failed'});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Unexpected error'});
}
