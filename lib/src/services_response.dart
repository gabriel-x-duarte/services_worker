import 'services_error.dart';

/// Represents the result of a task executed by [ServicesWorker].
///
/// A [ServicesResponse] can represent either a successful result or
/// a failure.
///
/// Unlike checking only whether [data] is `null`, this class uses
/// [isSuccess] to identify success. This allows `null` to be treated
/// as a valid successful result.
final class ServicesResponse<R> {
  /// The data returned by a successful task.
  ///
  /// This value can be `null` when the task intentionally returns `null`.
  final R? data;

  /// The error returned when the task fails.
  final ServicesFailure<Object>? error;

  /// Whether the task completed successfully.
  final bool isSuccess;

  const ServicesResponse._({
    required this.data,
    required this.error,
    required this.isSuccess,
  });

  /// Creates a successful response.
  ///
  /// The [data] value can be `null`.
  const ServicesResponse.success(R? data)
      : this._(
          data: data,
          error: null,
          isSuccess: true,
        );

  /// Creates an error response.
  const ServicesResponse.error(ServicesFailure<Object> error)
      : this._(
          data: null,
          error: error,
          isSuccess: false,
        );

  /// Whether the task failed.
  bool get isFailure => !isSuccess;

  /// Whether this response contains an error.
  bool get hasError => error != null;

  /// Whether this response contains non-null data.
  ///
  /// This getter only checks whether [data] is different from `null`.
  /// A successful response may still have `null` data when `R` is nullable.
  bool get hasData => data != null;

  @override
  String toString() {
    return <String, Object?>{
      'data': data,
      'error': error,
      'isSuccess': isSuccess,
    }.toString();
  }
}
