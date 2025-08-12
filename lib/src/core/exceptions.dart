class FirestoreException implements Exception {
  final String message;
  final dynamic originalError;

  FirestoreException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

class AuthException implements Exception {
  final String message;
  final dynamic originalError;

  AuthException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return '$message (Field errors: ${fieldErrors.toString()})';
    }
    return message;
  }
}
