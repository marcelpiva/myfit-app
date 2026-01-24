/// API Exception classes for MyFit app
/// Provides typed exceptions for different HTTP error scenarios

/// Base class for all API exceptions
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// 401 Unauthorized - Invalid or expired authentication
class AuthenticationException extends ApiException {
  const AuthenticationException([
    String message = 'Sessão expirada. Faça login novamente.',
  ]) : super(message, statusCode: 401);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// 403 Forbidden - User doesn't have permission
class ForbiddenException extends ApiException {
  const ForbiddenException([
    String message = 'Você não tem permissão para realizar esta ação.',
  ]) : super(message, statusCode: 403);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// 404 Not Found - Resource doesn't exist
class NotFoundException extends ApiException {
  const NotFoundException([
    String message = 'Recurso não encontrado.',
  ]) : super(message, statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// 400 Bad Request - Validation errors
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    String message, {
    this.fieldErrors,
  }) : super(message, statusCode: 400);

  @override
  String toString() => 'ValidationException: $message';

  /// Get first error for a specific field
  String? getFieldError(String field) {
    return fieldErrors?[field]?.firstOrNull;
  }

  /// Get all errors as a single string
  String get allErrorsAsString {
    if (fieldErrors == null || fieldErrors!.isEmpty) return message;
    return fieldErrors!.entries
        .map((e) => '${e.key}: ${e.value.join(", ")}')
        .join('\n');
  }
}

/// 409 Conflict - Resource already exists
class ConflictException extends ApiException {
  const ConflictException([
    String message = 'Este recurso já existe.',
  ]) : super(message, statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}

/// 429 Too Many Requests - Rate limit exceeded
class RateLimitException extends ApiException {
  const RateLimitException([
    String message = 'Muitas requisições. Aguarde um momento e tente novamente.',
  ]) : super(message, statusCode: 429);

  @override
  String toString() => 'RateLimitException: $message';
}

/// 500+ Server Error - Backend error
class ServerException extends ApiException {
  const ServerException([
    String message = 'Erro no servidor. Tente novamente mais tarde.',
    int? statusCode,
  ]) : super(message, statusCode: statusCode ?? 500);

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Network Error - No internet connection or timeout
class NetworkException extends ApiException {
  final bool isTimeout;

  const NetworkException({
    String message = 'Sem conexão com a internet.',
    this.isTimeout = false,
  }) : super(message);

  factory NetworkException.timeout() => const NetworkException(
        message: 'Tempo de conexão esgotado. Verifique sua internet.',
        isTimeout: true,
      );

  factory NetworkException.noConnection() => const NetworkException(
        message: 'Sem conexão com a internet.',
        isTimeout: false,
      );

  @override
  String toString() => 'NetworkException: $message (timeout: $isTimeout)';
}

/// Unknown Error - Unexpected error
class UnknownApiException extends ApiException {
  const UnknownApiException([
    String message = 'Ocorreu um erro inesperado.',
    dynamic originalError,
  ]) : super(message, originalError: originalError);

  @override
  String toString() => 'UnknownApiException: $message';
}

/// Extension to get user-friendly error messages
extension ApiExceptionMessage on ApiException {
  /// Get a user-friendly message suitable for displaying in UI
  String get userMessage {
    // Use the actual message from the exception if available
    final msg = message;
    if (msg.isNotEmpty && msg != 'Sessão expirada. Faça login novamente.') {
      // Return the API message directly for authentication errors
      if (this is AuthenticationException) return msg;
    }

    return switch (this) {
      AuthenticationException() => msg.isNotEmpty ? msg : 'Sessão expirada. Faça login novamente.',
      ForbiddenException() => msg.isNotEmpty ? msg : 'Você não tem permissão para esta ação.',
      NotFoundException() => msg.isNotEmpty ? msg : 'Não encontrado.',
      ValidationException() => msg,
      ConflictException() => msg.isNotEmpty ? msg : 'Este item já existe.',
      RateLimitException() => 'Muitas requisições. Aguarde um momento.',
      ServerException() => msg.isNotEmpty ? msg : 'Erro no servidor. Tente novamente.',
      NetworkException(isTimeout: true) => 'Conexão lenta. Tente novamente.',
      NetworkException() => 'Sem conexão com a internet.',
      UnknownApiException() => msg.isNotEmpty ? msg : 'Ocorreu um erro. Tente novamente.',
    };
  }

  /// Check if error is retryable
  bool get isRetryable {
    return switch (this) {
      NetworkException() => true,
      ServerException(statusCode: final code) => code != null && code >= 500,
      _ => false,
    };
  }
}
