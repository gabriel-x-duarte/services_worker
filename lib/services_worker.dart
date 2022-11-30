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
    FutureOr<R> Function() task,
  ) async {
    try {
      R data = await task();

      return ServicesResponse<R>.success(data);
    } catch (e) {
      final ServicesError error = e is ServicesException
          ? e
          : ServicesError(
              e.toString(),
              data: e,
              type: e.runtimeType,
            );

      return ServicesResponse<R>.error(error);
    }
  }

  /// Executes a task in another thread.
  ///
  /// If R is of type void, the property ServicesResponse.data
  /// will be inaccessible. In this case which nothing is returned,
  /// is recommended to use type Null instead of void.
  ///
  /// Any functions called inside the passing function, must be static.
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
    Q payload,
  ) async {
    try {
      final R data = await compute<Q, R>(task, payload);

      return ServicesResponse<R>.success(data);
    } catch (e) {
      final ServicesError error = e is ServicesException
          ? e
          : ServicesError(
              e.toString(),
              data: e,
              type: e.runtimeType,
            );

      return ServicesResponse<R>.error(error);
    }
  }
}

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

  bool get hasData => data != null ? true : false;

  bool get hasError => error != null ? true : false;

  @override
  String toString() {
    return <String, String>{
      "data": data.toString(),
      "error": error.toString(),
    }.toString();
  }
}

class ServicesError {
  final String message;
  final Object? data;
  final Type? type;

  const ServicesError(
    this.message, {
    this.data,
    this.type,
  });

  @override
  String toString() {
    return <String, String>{
      "message": message,
      "data": data.toString(),
      "type": type.toString(),
    }.toString();
  }
}

class ServicesException extends ServicesError implements Exception {
  const ServicesException(
    super.message, {
    super.data,
  }) : super(
          type: ServicesException,
        );

  @override
  String toString() {
    return <String, String>{
      "message": message,
      "data": data.toString(),
      "type": type.toString(),
    }.toString();
  }
}
