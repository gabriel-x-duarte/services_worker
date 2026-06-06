// ignore_for_file: avoid_print

import 'package:services_worker/services_worker.dart';

Future<void> main() async {
  const ServicesWorker worker = ServicesWorker();

  // =========================================================
  // 1. Synchronous task
  // =========================================================

  final ServicesResponse<int> syncResponse = await worker.run<int>(
    () {
      return 8 + 8;
    },
  );

  if (syncResponse.isSuccess) {
    print(
      'Synchronous result: ${syncResponse.data}',
    );
  }

  // =========================================================
  // 2. Asynchronous task
  // =========================================================

  final ServicesResponse<String> asyncResponse = await worker.run<String>(
    () async {
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      return 'Async task completed';
    },
  );

  if (asyncResponse.isSuccess) {
    print(
      'Asynchronous result: ${asyncResponse.data}',
    );
  }

  // =========================================================
  // 3. Nullable successful result
  // =========================================================

  final ServicesResponse<String?> nullableResponse = await worker.run<String?>(
    () {
      return null;
    },
  );

  print(
    'Nullable success: ${nullableResponse.isSuccess}',
  );

  print(
    'Nullable hasData: ${nullableResponse.hasData}',
  );

  // =========================================================
  // 4. Common exception handling
  // =========================================================

  final ServicesResponse<void> commonErrorResponse = await worker.run<void>(
    () {
      throw Exception('Unexpected error');
    },
  );

  if (commonErrorResponse.hasFailure) {
    print(
      'Common failure message: '
      '${commonErrorResponse.failure?.message}',
    );

    print(
      'Common failure stackTrace: '
      '${commonErrorResponse.failure?.stackTrace}',
    );
  }

  // =========================================================
  // 5. Structured failure handling
  // =========================================================

  final ServicesResponse<void> structuredFailureResponse =
      await worker.run<void>(
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

  if (structuredFailureResponse.hasFailure) {
    final ServicesFailure? failure = structuredFailureResponse.failure;

    print(
      'Structured failure message: '
      '${failure?.message}',
    );

    print(
      'Structured failure code: '
      '${failure?.code}',
    );

    print(
      'Structured failure logs: '
      '${failure?.logs}',
    );
  }

  // =========================================================
  // 6. Custom failure mapping
  // =========================================================

  final ServicesResponse<void> customFailureResponse = await worker.run<void>(
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

  if (customFailureResponse.hasFailure) {
    print(
      'Custom failure: '
      '${customFailureResponse.failure?.message}',
    );
  }

  // =========================================================
  // 7. Isolate execution
  // =========================================================

  final ServicesResponse<int> isolateResponse = await worker.runInIsolate<int>(
    heavyCalculation,
  );

  if (isolateResponse.isSuccess) {
    print(
      'Isolate result: ${isolateResponse.data}',
    );
  }
}

int heavyCalculation() {
  int total = 0;

  for (int i = 0; i < 1000000; i++) {
    total += i;
  }

  return total;
}
