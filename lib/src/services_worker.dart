import 'dart:async';
import 'dart:isolate';

import 'services_error.dart';
import 'services_exception.dart';
import 'services_response.dart';

/// A lightweight worker responsible for safely running tasks.
///
/// [ServicesWorker] can run synchronous tasks, asynchronous tasks,
/// and isolate-based tasks while converting successful results and
/// failures into [ServicesResponse] objects.
///
/// This class is intentionally instantiable so it can be injected
/// into services, repositories, use cases, interactors, or controllers.
final class ServicesWorker {
  /// Creates a new [ServicesWorker] instance.
  const ServicesWorker();

  /// Runs a task safely in the current isolate.
  ///
  /// The [task] can be either synchronous or asynchronous.
  ///
  /// If the task completes successfully, this method returns
  /// [ServicesResponse.success].
  ///
  /// If the task throws, this method returns [ServicesResponse.error].
  ///
  /// The optional [onError] callback allows custom error mapping.
  ///
  /// Example:
  ///
  /// ```dart
  /// final worker = ServicesWorker();
  ///
  /// final response = await worker.run<int>(
  ///   () async {
  ///     await Future<void>.delayed(const Duration(milliseconds: 300));
  ///     return 8 + 8;
  ///   },
  /// );
  /// ```
  Future<ServicesResponse<R>> run<R>(
    FutureOr<R> Function() task, {
    FutureOr<ServicesResponse<R>> Function(
      Object error,
      StackTrace stackTrace,
    )? onError,
  }) async {
    try {
      final R data = await task();

      return ServicesResponse<R>.success(data);
    } catch (error, stackTrace) {
      if (onError != null) {
        return onError(error, stackTrace);
      }

      return ServicesResponse<R>.error(
        _mapError(
          error,
          stackTrace,
        ),
      );
    }
  }

  /// Runs a task safely in another isolate.
  ///
  /// This method is useful for CPU-heavy operations that should not
  /// block the current isolate.
  ///
  /// The [task] must be compatible with Dart isolate restrictions.
  /// In practice, avoid closures that capture non-sendable objects.
  /// Prefer top-level functions, static functions, or simple closures
  /// that only capture sendable values.
  ///
  /// If the task completes successfully, this method returns
  /// [ServicesResponse.success].
  ///
  /// If the task throws, this method returns [ServicesResponse.error].
  ///
  /// The optional [onError] callback allows custom error mapping.
  ///
  /// Example:
  ///
  /// ```dart
  /// int calculate() {
  ///   return 40 + 2;
  /// }
  ///
  /// final worker = ServicesWorker();
  ///
  /// final response = await worker.runInIsolate<int>(
  ///   calculate,
  /// );
  /// ```
  Future<ServicesResponse<R>> runInIsolate<R>(
    FutureOr<R> Function() task, {
    FutureOr<ServicesResponse<R>> Function(
      Object error,
      StackTrace stackTrace,
    )? onError,
  }) async {
    try {
      final R data = await Isolate.run(task);

      return ServicesResponse<R>.success(data);
    } catch (error, stackTrace) {
      if (onError != null) {
        return onError(error, stackTrace);
      }

      return ServicesResponse<R>.error(
        _mapError(
          error,
          stackTrace,
        ),
      );
    }
  }

  ServicesFailure<Object> _mapError(
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ServicesException<Object>) {
      return error.toServicesError(
        additionalLogs: <String>[
          stackTrace.toString(),
        ],
      );
    }

    return ServicesFailure<Object>(
      message: error.toString(),
      logs: <String>[
        stackTrace.toString(),
      ],
      data: error,
    );
  }
}

/// A shared default [ServicesWorker] instance.
///
/// This constant is provided only as a convenience for applications
/// that do not need dependency injection.
///
/// Example:
///
/// ```dart
/// final response = await servicesWorker.run(
///   () => 'Done',
/// );
/// ```
const ServicesWorker servicesWorker = ServicesWorker();
