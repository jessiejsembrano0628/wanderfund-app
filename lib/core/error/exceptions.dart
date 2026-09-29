class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error'});
}

class ServerException extends AppException {
  ServerException({super.message = 'Server error', super.code});
}

class AuthenticationException extends AppException {
  AuthenticationException({super.message = 'Authentication failed'});
}

class CacheException extends AppException {
  CacheException({super.message = 'Cache error'});
}

class InvalidInputException extends AppException {
  InvalidInputException({required super.message});
}
