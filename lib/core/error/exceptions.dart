class ServerException implements Exception {
  final String message;
  final String? code;
  
  const ServerException(this.message, [this.code]);
}

class NetworkException implements Exception {
  final String message;
  final String? code;
  
  const NetworkException(this.message, [this.code]);
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException(this.message, [this.code]);
}

class ValidationException implements Exception {
  final String message;
  final String? code;
  
  const ValidationException(this.message, [this.code]);
}

class NotFoundException implements Exception {
  final String message;
  final String? code;
  
  const NotFoundException(this.message, [this.code]);
}

class CacheException implements Exception {
  final String message;
  final String? code;
  
  const CacheException(this.message, [this.code]);
}

class PermissionException implements Exception {
  final String message;
  final String? code;
  
  const PermissionException(this.message, [this.code]);
}