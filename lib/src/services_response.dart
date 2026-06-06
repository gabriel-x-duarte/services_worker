import 'services_failure.dart';

/// Represents the result of a task executed by [ServicesWorker].
///
/// A [ServicesResponse] can represent either a successful result or
/// a failure.
///
/// This class is intentionally explicit about operation state.
/// Success is represented by [isSuccess], failure is represented by
/// [isFailure], and the presence of non-null data is represented by
/// [hasData].
///
/// This distinction is important because a task can complete
/// successfully and still return `null` when the expected type is
/// nullable.
final class ServicesResponse<R> {
  /// The data returned by a successful task.
  ///
  /// This value can be `null` when the task intentionally returns `null`.
  final R? data;

  /// The failure returned when the task fails.
  ///
  /// This value is `null` when [isSuccess] is `true`.
  final ServicesFailure? failure;

  /// Whether the task completed successfully.
  final bool isSuccess;

  const ServicesResponse._({
    required this.data,
    required this.failure,
    required this.isSuccess,
  });

  /// Creates a successful response.
  ///
  /// The [data] value can be `null`.
  const ServicesResponse.success(R? data)
      : this._(
          data: data,
          failure: null,
          isSuccess: true,
        );

  /// Creates a failure response.
  const ServicesResponse.failure(ServicesFailure failure)
      : this._(
          data: null,
          failure: failure,
          isSuccess: false,
        );

  /// Whether the task failed.
  bool get isFailure => !isSuccess;

  /// Whether this response contains a failure.
  bool get hasFailure => failure != null;

  /// Whether this response contains non-null data.
  ///
  /// This getter only checks whether [data] is different from `null`.
  /// A response can be successful and still return `false` here when
  /// the expected result is nullable and the actual value is `null`.
  bool get hasData => data != null;

  @override
  String toString() {
    return <String, Object?>{
      'data': data,
      'failure': failure,
      'isSuccess': isSuccess,
    }.toString();
  }
}
