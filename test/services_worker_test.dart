import 'package:test/test.dart';
import 'package:services_worker/services_worker.dart';

void main() {
  group('ServicesWorker.run', () {
    test('returns success with synchronous value', () async {
      const worker = ServicesWorker();

      final response = await worker.run<int>(
        () => 8 + 8,
      );

      expect(response.isSuccess, isTrue);
      expect(response.isFailure, isFalse);
      expect(response.hasData, isTrue);
      expect(response.hasFailure, isFalse);
      expect(response.data, equals(16));
      expect(response.failure, isNull);
    });

    test('returns success with asynchronous value', () async {
      const worker = ServicesWorker();

      final response = await worker.run<String>(
        () async {
          await Future<void>.delayed(
            const Duration(milliseconds: 10),
          );

          return 'completed';
        },
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasData, isTrue);
      expect(response.data, equals('completed'));
      expect(response.failure, isNull);
    });

    test('returns success with null value', () async {
      const worker = ServicesWorker();

      final response = await worker.run<String?>(
        () => null,
      );

      expect(response.isSuccess, isTrue);
      expect(response.isFailure, isFalse);
      expect(response.hasData, isFalse);
      expect(response.hasFailure, isFalse);
      expect(response.data, isNull);
      expect(response.failure, isNull);
    });

    test('captures common exception as failure', () async {
      const worker = ServicesWorker();

      final response = await worker.run<Null>(
        () {
          throw Exception('Unexpected error');
        },
      );

      expect(response.isSuccess, isFalse);
      expect(response.isFailure, isTrue);
      expect(response.hasData, isFalse);
      expect(response.hasFailure, isTrue);
      expect(response.data, isNull);

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.message, contains('Unexpected error'));
      expect(failure.code, equals(''));
      expect(failure.logs, isEmpty);
      expect(failure.error, isA<Exception>());
      expect(failure.stackTrace, isNotNull);
    });

    test('captures ServicesException as structured failure', () async {
      const worker = ServicesWorker();

      final response = await worker.run<void>(
        () {
          throw const ServicesException(
            message: 'Invalid credentials',
            code: 'AUTH_INVALID_CREDENTIALS',
            logs: <String>[
              'Authentication module',
              'Login use case',
            ],
          );
        },
      );

      expect(response.isSuccess, isFalse);
      expect(response.hasFailure, isTrue);

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.message, equals('Invalid credentials'));
      expect(failure.code, equals('AUTH_INVALID_CREDENTIALS'));
      expect(
        failure.logs,
        equals(
          <String>[
            'Authentication module',
            'Login use case',
          ],
        ),
      );
      expect(failure.error, isA<ServicesException>());
      expect(failure.stackTrace, isNotNull);
    });

    test('preserves ServicesException original stackTrace when provided',
        () async {
      const worker = ServicesWorker();
      final originalStackTrace = StackTrace.current;

      final response = await worker.run<void>(
        () {
          throw ServicesException(
            message: 'Failure with original stack trace',
            stackTrace: originalStackTrace,
          );
        },
      );

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.stackTrace, same(originalStackTrace));
    });

    test('uses caught stackTrace when ServicesException has no stackTrace',
        () async {
      const worker = ServicesWorker();

      final response = await worker.run<void>(
        () {
          throw const ServicesException(
            message: 'Failure without original stack trace',
          );
        },
      );

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.stackTrace, isNotNull);
    });

    test('uses custom onError mapper', () async {
      const worker = ServicesWorker();

      final response = await worker.run<void>(
        () {
          throw Exception('Database unavailable');
        },
        onError: (
          Object error,
          StackTrace stackTrace,
        ) {
          return ServicesResponse<void>.failure(
            ServicesFailure(
              message: 'Custom database failure',
              code: 'DATABASE_ERROR',
              logs: <String>[
                'Custom error mapper',
              ],
              error: error,
              stackTrace: stackTrace,
            ),
          );
        },
      );

      expect(response.isSuccess, isFalse);
      expect(response.hasFailure, isTrue);

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.message, equals('Custom database failure'));
      expect(failure.code, equals('DATABASE_ERROR'));
      expect(
        failure.logs,
        equals(
          <String>[
            'Custom error mapper',
          ],
        ),
      );
      expect(failure.error, isA<Exception>());
      expect(failure.stackTrace, isNotNull);
    });
  });

  group('ServicesWorker.runInIsolate', () {
    test('returns success with isolate value', () async {
      const worker = ServicesWorker();

      final response = await worker.runInIsolate<int>(
        heavyCalculation,
      );

      expect(response.isSuccess, isTrue);
      expect(response.isFailure, isFalse);
      expect(response.hasData, isTrue);
      expect(response.hasFailure, isFalse);
      expect(response.data, equals(499999500000));
      expect(response.failure, isNull);
    });

    test('captures isolate exception as failure', () async {
      const worker = ServicesWorker();

      final response = await worker.runInIsolate<void>(
        throwInIsolate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.isFailure, isTrue);
      expect(response.hasFailure, isTrue);

      final failure = response.failure;

      expect(failure, isNotNull);
      expect(failure!.message, contains('Isolate failure'));
      expect(failure.error, isNotNull);
      expect(failure.stackTrace, isNotNull);
    });
  });

  group('ServicesResponse', () {
    test('success constructor creates successful response', () {
      const response = ServicesResponse<int>.success(10);

      expect(response.data, equals(10));
      expect(response.failure, isNull);
      expect(response.isSuccess, isTrue);
      expect(response.isFailure, isFalse);
      expect(response.hasData, isTrue);
      expect(response.hasFailure, isFalse);
    });

    test('failure constructor creates failure response', () {
      const failure = ServicesFailure(
        message: 'Failure',
        code: 'FAILURE',
      );

      const response = ServicesResponse<int>.failure(failure);

      expect(response.data, isNull);
      expect(response.failure, same(failure));
      expect(response.isSuccess, isFalse);
      expect(response.isFailure, isTrue);
      expect(response.hasData, isFalse);
      expect(response.hasFailure, isTrue);
    });
  });

  group('ServicesFailure', () {
    test('copyWith overrides non-null values', () {
      const failure = ServicesFailure(
        message: 'Original message',
        code: 'ORIGINAL_CODE',
        logs: <String>[
          'original log',
        ],
      );

      final copied = failure.copyWith(
        message: 'New message',
        code: 'NEW_CODE',
        logs: <String>[
          'new log',
        ],
      );

      expect(copied.message, equals('New message'));
      expect(copied.code, equals('NEW_CODE'));
      expect(
        copied.logs,
        equals(
          <String>[
            'new log',
          ],
        ),
      );
    });

    test('copyWith keeps current values when parameters are null', () {
      final originalError = Object();
      final originalStackTrace = StackTrace.current;

      final failure = ServicesFailure(
        message: 'Original message',
        code: 'ORIGINAL_CODE',
        logs: const <String>[
          'original log',
        ],
        error: originalError,
        stackTrace: originalStackTrace,
      );

      final copied = failure.copyWith();

      expect(copied.message, equals(failure.message));
      expect(copied.code, equals(failure.code));
      expect(copied.logs, same(failure.logs));
      expect(copied.error, same(originalError));
      expect(copied.stackTrace, same(originalStackTrace));
    });

    test('copyWithAdditionalLogs appends logs', () {
      const failure = ServicesFailure(
        message: 'Failure',
        logs: <String>[
          'first log',
        ],
      );

      final copied = failure.copyWithAdditionalLogs(
        <String>[
          'second log',
          'third log',
        ],
      );

      expect(
        copied.logs,
        equals(
          <String>[
            'first log',
            'second log',
            'third log',
          ],
        ),
      );
    });
  });

  group('ServicesException', () {
    test('fromServicesFailure creates exception from failure', () {
      final error = Object();
      final stackTrace = StackTrace.current;

      final failure = ServicesFailure(
        message: 'Failure message',
        code: 'FAILURE_CODE',
        logs: const <String>[
          'failure log',
        ],
        error: error,
        stackTrace: stackTrace,
      );

      final exception = ServicesException.fromServicesFailure(failure);

      expect(exception.message, equals(failure.message));
      expect(exception.code, equals(failure.code));
      expect(exception.logs, same(failure.logs));
      expect(exception.error, same(error));
      expect(exception.stackTrace, same(stackTrace));
    });

    test('toServicesFailure preserves structured information', () {
      final error = Object();
      final stackTrace = StackTrace.current;

      final exception = ServicesException(
        message: 'Exception message',
        code: 'EXCEPTION_CODE',
        logs: const <String>[
          'exception log',
        ],
        error: error,
        stackTrace: stackTrace,
      );

      final failure = exception.toServicesFailure();

      expect(failure.message, equals(exception.message));
      expect(failure.code, equals(exception.code));
      expect(failure.logs, same(exception.logs));
      expect(failure.error, same(error));
      expect(failure.stackTrace, same(stackTrace));
    });

    test('toServicesFailure uses exception itself as error when error is null',
        () {
      const exception = ServicesException(
        message: 'Exception message',
      );

      final failure = exception.toServicesFailure();

      expect(failure.error, same(exception));
    });
  });
}

int heavyCalculation() {
  int total = 0;

  for (int i = 0; i < 1000000; i++) {
    total += i;
  }

  return total;
}

void throwInIsolate() {
  throw Exception('Isolate failure');
}
