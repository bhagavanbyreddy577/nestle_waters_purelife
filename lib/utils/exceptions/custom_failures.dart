import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic data;
  final dynamic error;

  const Failure({
    required this.message,
    this.code,
    this.data,
    this.error,
  });

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() {
    return 'Failure: $message (code: $code)';
  }
}

/// Server-side failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
    dynamic data,
    dynamic error,
  }) : super(
    message: message,
    code: code,
    data: data,
    error: error,
  );
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    dynamic error,
  }) : super(
    message: message,
    error: error,
  );
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    int? code,
    dynamic data,
    dynamic error,
  }) : super(
    message: message,
    code: code,
    data: data,
    error: error,
  );
}

/// Resource not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required String message,
    int? code,
    dynamic data,
    dynamic error,
  }) : super(
    message: message,
    code: code,
    data: data,
    error: error,
  );
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    int? code,
    dynamic data,
    dynamic error,
  }) : super(
    message: message,
    code: code,
    data: data,
    error: error,
  );
}

/// Rate limit failures
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    required String message,
    int? code,
    dynamic data,
    dynamic error,
  }) : super(
    message: message,
    code: code,
    data: data,
    error: error,
  );
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required String message,
    dynamic error,
  }) : super(
    message: message,
    error: error,
  );
}

/// Cancelled request failures
class CancelledFailure extends Failure {
  const CancelledFailure({
    required String message,
    dynamic error,
  }) : super(
    message: message,
    error: error,
  );
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    dynamic error,
  }) : super(
    message: message,
    error: error,
  );
}

/// No data failures
class NoDataFailure extends Failure {
  const NoDataFailure({
    required String message,
    dynamic error,
  }) : super(
    message: message,
    error: error,
  );
}