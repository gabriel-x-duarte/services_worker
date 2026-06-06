import 'services_failure.dart';

/// A custom exception that can be thrown inside a task executed by
/// [ServicesWorker].
///
/// Because [ServicesException] extends [ServicesFailure], it carries
/// the same structured information as a returned failure while also
/// being throwable as an [Exception].
///
/// This is useful when application code wants to throw a structured
/// failure and still allow [ServicesWorker] to convert it back into
/// a [ServicesFailure] response.
final class ServicesException extends ServicesFailure implements Exception {
  /// Creates a [ServicesException].
  const ServicesException({
    required super.message,
    super.code,
    super.logs,
    super.error,
    super.stackTrace,
  });

  /// Creates a [ServicesException] from a [ServicesFailure].
  factory ServicesException.fromServicesFailure(
    ServicesFailure failure,
  ) {
    return ServicesException(
      message: failure.message,
      code: failure.code,
      logs: failure.logs,
      error: failure.error,
      stackTrace: failure.stackTrace,
    );
  }

  /// Converts this exception into a [ServicesFailure].
  ///
  /// This method preserves the structured information stored in this
  /// exception.
  ///
  /// It does not receive or override external execution context.
  /// Any additional mapping, such as attaching a caught stack trace when
  /// this exception does not already contain one, should be handled by
  /// the caller.
  ServicesFailure toServicesFailure() {
    return ServicesFailure(
      message: message,
      code: code,
      logs: logs,
      error: error ?? this,
      stackTrace: stackTrace,
    );
  }
}
