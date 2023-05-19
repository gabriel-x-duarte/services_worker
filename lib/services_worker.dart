library services_worker;

import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ServicesWorker {
  /// Executes a task in the main running thread.
  ///
  /// If R is of type void, the property ServicesResponse.data
  /// will be inaccessible. In this case which nothing is returned,
  /// is recommended to use type Null instead of void.
  ///
  /// Example:
  /// ```dart
  /// ServicesWorker.execute<Null>(
  ///   () {
  ///     doSomething();
  ///     return;
  ///   },
  /// );
  ///
  /// ServicesWorker.execute<int>(
  ///   () async {
  ///     await Future.delayed(const Duration(milliseconds: 1000));
  ///
  ///     return 8 + 8;
  ///   },
  /// );
  /// ```
  static Future<ServicesResponse<R>> execute<R>(
    FutureOr<R> Function() task, {
    FutureOr<ServicesResponse<R>> Function(
      Object error,
      StackTrace stackTrace,
    )? onError,
  }) async {
    try {
      R data = await task();

      return ServicesResponse<R>.success(data);
    } catch (err, stackTrace) {
      if (onError == null) {
        final ServicesError error = err is ServicesException
            ? err.toServicesError(
                [stackTrace.toString()],
              )
            : ServicesError(
                message: err.runtimeType.toString(),
                logs: [stackTrace.toString()],
                data: err,
              );

        return ServicesResponse<R>.error(error);
      }

      return await onError(
        err,
        stackTrace,
      );
    }
  }

  /// Executes a task in another thread.
  ///
  /// If R is of type void, the property ServicesResponse.data
  /// will be inaccessible. In this case which nothing is returned,
  /// is recommended to use type Null instead of void.
  ///
  /// Any functions called inside the passing Function() task, must be static.
  /// Otherwise it will throw an exeception when executing the isolate.
  ///
  /// Example:
  /// ```dart
  /// ServicesWorker.executeInOtherThread<int, int>(
  ///   (int n) {
  ///     return n + n;
  ///   },
  ///   4,
  /// );
  ///
  /// ServicesWorker.executeInOtherThread<int, Null>(
  ///   (int n) async {
  ///     await Future.delayed(const Duration(milliseconds: 1000));
  ///
  ///     doSomething(); // this function is static
  ///     return;
  ///   },
  ///   4,
  /// );
  /// ```
  static Future<ServicesResponse<R>> executeInOtherThread<Q, R>(
    FutureOr<R> Function(Q) task,
    Q payload, {
    FutureOr<ServicesResponse<R>> Function(
      Object error,
      StackTrace stackTrace,
    )? onError,
  }) async {
    try {
      final R data = await compute<Q, R>(task, payload);

      return ServicesResponse<R>.success(data);
    } catch (err, stackTrace) {
      if (onError == null) {
        final ServicesError error = err is ServicesException
            ? err.toServicesError(
                [stackTrace.toString()],
              )
            : ServicesError(
                message: err.runtimeType.toString(),
                logs: [stackTrace.toString()],
                data: err,
              );

        return ServicesResponse<R>.error(error);
      }

      return await onError(
        err,
        stackTrace,
      );
    }
  }
}

/// This class has two constructors to ensure that it will either return
/// an error, or the expected type of data informed.
class ServicesResponse<R> {
  final R? data;
  final ServicesError? error;

  const ServicesResponse._({
    required this.data,
    required this.error,
  });

  factory ServicesResponse.success(R data) => ServicesResponse<R>._(
        data: data,
        error: null,
      );

  factory ServicesResponse.error(ServicesError error) => ServicesResponse<R>._(
        data: null,
        error: error,
      );

  /// Returns true if data != null
  bool get hasData => data != null ? true : false;

  /// Returns true if error != null
  bool get hasError => error != null ? true : false;

  @override
  String toString() {
    return <String, String>{
      "data": data.toString(),
      "error": error.toString(),
    }.toString();
  }
}

/// Base Error class
class ServicesError<E> {
  final String message;
  final String code;
  final List<String> logs;
  final E? data;

  const ServicesError({
    required this.message,
    this.code = "",
    this.logs = const [],
    this.data,
  });

  factory ServicesError.fromServicesException(
    ServicesException<E> exception,
  ) {
    final ServicesError<E> err = exception;

    return err;
  }

  ServicesError<E> copyWithAdditionalLogs(List<String> additionalLogs) {
    final List<String> newLogList = [
      ...logs,
      ...additionalLogs,
    ];

    return ServicesError<E>(
      message: message,
      logs: newLogList,
      data: data,
    );
  }

  @override
  String toString() {
    return <String, String>{
      "message": message,
      "code": code,
      "logs": logs.toString(),
      "data": data.toString(),
    }.toString();
  }
}

class ServicesException<E> extends ServicesError<E> implements Exception {
  const ServicesException({
    required super.message,
    super.code,
    super.logs,
    super.data,
  });

  factory ServicesException.fromServicesError(ServicesError<E> error) {
    return ServicesException<E>(
      message: error.message,
      code: error.code,
      logs: error.logs,
      data: error.data,
    );
  }

  ServicesError<E> toServicesError(
    List<String>? additionalLogs,
  ) {
    if (additionalLogs != null) {
      final ServicesError<E> err = super.copyWithAdditionalLogs(
        additionalLogs,
      );

      return err;
    }

    return this;
  }

  @override
  String toString() {
    return <String, String>{
      "message": message,
      "code": code,
      "logs": logs.toString(),
      "data": data.toString(),
    }.toString();
  }
}
