import 'dart:async';
import 'dart:isolate';

import 'services_exception.dart';
import 'services_failure.dart';
import 'services_response.dart';

/// A lightweight worker responsible for safely running tasks.
///
/// [ServicesWorker] can run synchronous tasks, asynchronous tasks,
/// and isolate-based tasks while converting successful results and
/// failures into [ServicesResponse] objects.
///
/// This class is intentionally instantiable so it can be injected
/// into services, repositories, use cases, interactors, controllers,
/// or any other application layer component.
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
  /// If the task throws, this method returns [ServicesResponse.failure].
  ///
  /// If no data is returned by the task, use `Null` instead of `void`
  /// as the generic type parameter.
  ///
  /// Using `void` makes `response.data` inaccessible and unsafe to
  /// consume, because `void` tells Dart that the returned value should
  /// not be used.
  ///
  /// Using `Null` keeps `response.data` accessible and explicitly
  /// represents the absence of data.
  ///
  /// Example:
  ///
  /// ```dart
  /// final response = await worker.run<Null>(
  ///   () {
  ///     performSideEffect();
  ///
  ///     return null;
  ///   },
  /// );
  /// ```
  ///
  /// The optional [onError] callback allows custom failure mapping.
  /// This is useful when the application needs to convert exceptions,
  /// infrastructure errors, or domain-specific problems into its own
  /// response format.
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

      return ServicesResponse<R>.failure(
        _mapFailure(
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
  /// If the task throws, this method returns [ServicesResponse.failure].
  ///
  /// If no data is returned by the task, use `Null` instead of `void`
  /// as the generic type parameter.
  ///
  /// Using `void` makes `response.data` inaccessible and unsafe to
  /// consume, because `void` tells Dart that the returned value should
  /// not be used.
  ///
  /// Using `Null` keeps `response.data` accessible and explicitly
  /// represents the absence of data.
  ///
  /// Example:
  ///
  /// ```dart
  /// final response = await worker.runInIsolate<Null>(
  ///   performSideEffectInIsolate,
  /// );
  /// ```
  ///
  /// The optional [onError] callback allows custom failure mapping.
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

      return ServicesResponse<R>.failure(
        _mapFailure(
          error,
          stackTrace,
        ),
      );
    }
  }

  ServicesFailure _mapFailure(
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ServicesException) {
      final ServicesFailure failure = error.toServicesFailure();

      if (failure.stackTrace != null) {
        return failure;
      }

      return failure.copyWith(
        stackTrace: stackTrace,
      );
    }

    return ServicesFailure(
      message: error.toString(),
      error: error,
      stackTrace: stackTrace,
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
