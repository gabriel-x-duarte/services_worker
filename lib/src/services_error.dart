/// Represents a structured error returned by [ServicesWorker].
///
/// This class is used when a task fails and the error needs to be
/// returned safely instead of being thrown to the caller.
class ServicesFailure<E> {
  /// A human-readable error message.
  final String message;

  /// An optional error code.
  final String code;

  /// Additional logs related to the error.
  ///
  /// This usually includes stack trace information.
  final List<String> logs;

  /// Optional custom error data.
  ///
  /// This can contain the original error object or any custom payload.
  final E? data;

  /// Creates a [ServicesError].
  const ServicesFailure({
    required this.message,
    this.code = '',
    this.logs = const <String>[],
    this.data,
  });

  /// Creates a copy of this error with additional logs.
  ServicesFailure<E> copyWithAdditionalLogs(
    List<String> additionalLogs,
  ) {
    return ServicesFailure<E>(
      message: message,
      code: code,
      logs: <String>[
        ...logs,
        ...additionalLogs,
      ],
      data: data,
    );
  }

  @override
  String toString() {
    return <String, Object?>{
      'message': message,
      'code': code,
      'logs': logs,
      'data': data,
    }.toString();
  }
}
