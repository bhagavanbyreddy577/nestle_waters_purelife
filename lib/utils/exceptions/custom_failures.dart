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
    required super.message,
    super.code,
    super.data,
    super.error,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.data,
    super.error,
  });
}

/// Resource not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.data,
    super.error,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.data,
    super.error,
  });
}

/// Rate limit failures
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    required super.message,
    super.code,
    super.data,
    super.error,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.error,
  });
}

/// Cancelled request failures
class CancelledFailure extends Failure {
  const CancelledFailure({
    required super.message,
    super.error,
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.error,
  });
}

/// No data failures
class NoDataFailure extends Failure {
  const NoDataFailure({
    required super.message,
    super.error,
  });
}