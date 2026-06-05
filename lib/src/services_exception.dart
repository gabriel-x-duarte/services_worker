import 'services_error.dart';

/// A custom exception that can be thrown inside a task executed by
/// [ServicesWorker].
///
/// When a [ServicesException] is thrown, [ServicesWorker] preserves
/// its structured information and converts it into a [ServicesError].
final class ServicesException<E> extends ServicesFailure<E>
    implements Exception {
  /// Creates a [ServicesException].
  const ServicesException({
    required super.message,
    super.code,
    super.logs,
    super.data,
  });

  /// Creates a [ServicesException] from a [ServicesError].
  factory ServicesException.fromServicesError(
    ServicesFailure<E> error,
  ) {
    return ServicesException<E>(
      message: error.message,
      code: error.code,
      logs: error.logs,
      data: error.data,
    );
  }

  /// Converts this exception into a [ServicesError].
  ///
  /// If [additionalLogs] is provided, the returned error will include
  /// both the current logs and the additional logs.
  ServicesFailure<E> toServicesError({
    List<String>? additionalLogs,
  }) {
    if (additionalLogs == null) {
      return this;
    }

    return copyWithAdditionalLogs(additionalLogs);
  }
}
