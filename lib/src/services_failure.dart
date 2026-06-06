/// Represents a structured failure returned by [ServicesWorker].
///
/// This class is used when a task fails and the failure needs to be
/// returned safely instead of being thrown to the caller.
///
/// [ServicesFailure] keeps the original [error] object and the
/// associated [stackTrace] separately. Because of that, [logs] should
/// be used for additional contextual information instead of duplicating
/// the stack trace as text.
class ServicesFailure {
  /// A human-readable failure message.
  ///
  /// This message should be safe to display, log, or inspect when
  /// debugging the failure.
  final String message;

  /// An optional failure code.
  ///
  /// This can be used by applications to identify specific failure
  /// categories, business rules, infrastructure errors, or integration
  /// errors.
  final String code;

  /// Additional logs related to the failure.
  ///
  /// This list is intended for contextual information, breadcrumbs,
  /// business flow details, or extra diagnostic messages.
  ///
  /// The stack trace is stored separately in [stackTrace].
  final List<String> logs;

  /// The original error object that caused the failure.
  ///
  /// This can be an exception, an error, or any object thrown by the task.
  final Object? error;

  /// The stack trace associated with the failure.
  ///
  /// This is stored separately from [logs] to preserve the original
  /// stack trace object and avoid duplicating diagnostic information
  /// as plain text.
  final StackTrace? stackTrace;

  /// Creates a [ServicesFailure].
  const ServicesFailure({
    required this.message,
    this.code = '',
    this.logs = const <String>[],
    this.error,
    this.stackTrace,
  });

  /// Creates a copy of this failure with overridden values.
  ///
  /// Any parameter left as `null` keeps the current value.
  ///
  /// Therefore, nullable fields cannot be cleared by passing `null`.
  ServicesFailure copyWith({
    String? message,
    String? code,
    List<String>? logs,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return ServicesFailure(
      message: message ?? this.message,
      code: code ?? this.code,
      logs: logs ?? this.logs,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  /// Creates a copy of this failure with additional logs.
  ///
  /// The new logs are appended after the existing [logs].
  ServicesFailure copyWithAdditionalLogs(
    List<String> additionalLogs,
  ) {
    return copyWith(
      logs: <String>[
        ...logs,
        ...additionalLogs,
      ],
    );
  }

  @override
  String toString() {
    return <String, Object?>{
      'message': message,
      'code': code,
      'logs': logs,
      'error': error,
      'stackTrace': stackTrace,
    }.toString();
  }
}
