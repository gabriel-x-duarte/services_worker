A lightweight Dart utility for safely running synchronous, asynchronous, and isolate-based tasks with structured responses.

## Features

* Run synchronous and asynchronous tasks safely.
* Run CPU-heavy tasks in another isolate.
* Convert thrown errors into structured failures.
* Preserve original error objects and stack traces.
* Support custom failure mapping.
* Pure Dart package with no Flutter dependency.
* Injectable `ServicesWorker` instances.
* Shared `servicesWorker` convenience instance.

## Usage

The following examples assume:

```dart
final worker = ServicesWorker();
```

#### Running tasks

```dart
final syncResponse = await worker.run<int>(
  () {
    return 8 + 8;
  },
);

final asyncResponse = await worker.run<String>(
  () async {
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    return 'Task completed';
  },
);

if (syncResponse.isSuccess) {
  print(syncResponse.data);
}

if (asyncResponse.isSuccess) {
  print(asyncResponse.data);
}
```

#### Running tasks in another isolate

Use `runInIsolate` for CPU-heavy operations that should not block the current isolate.

```dart
final response = await worker.runInIsolate<int>(
  heavyCalculation,
);

if (response.isSuccess) {
  print(response.data);
}

int heavyCalculation() {
  int total = 0;

  for (int i = 0; i < 1000000; i++) {
    total += i;
  }

  return total;
}
```

## Handling failures

#### Common exceptions

```dart
final response = await worker.run<Null>(
  () {
    throw Exception('Unexpected error');
  },
);

if (response.hasFailure) {
  final failure = response.failure!;

  print(failure.message);
  print(failure.error);
  print(failure.stackTrace);
}
```

#### Structured exceptions

```dart
final response = await worker.run<Null>(
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

if (response.hasFailure) {
  final failure = response.failure!;

  print(failure.message);
  print(failure.code);
  print(failure.logs);
}
```

#### Custom failure mapping

```dart
final response = await worker.run<int>(
  () {
    throw Exception('Database unavailable');
  },
  onError: (
    Object error,
    StackTrace stackTrace,
  ) {
    return ServicesResponse<int>.failure(
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

if (response.hasFailure) {
  print(response.failure!.message);
}
```

## Using `Null` instead of `void`

If no data is returned by the task, use `Null` instead of `void` as the generic type parameter.

Using `void` makes `response.data` inaccessible and unsafe to consume, because `void` tells Dart that the returned value should not be used.

Using `Null` keeps `response.data` accessible and explicitly represents the absence of data.

```dart
final response = await worker.run<Null>(
  () {
    print('Side effect completed');

    return null;
  },
);

print(response.isSuccess);
print(response.hasData);
print(response.data);
```

## Using the shared instance

If you do not need dependency injection, you can use the shared `servicesWorker` instance.

```dart
final response = await servicesWorker.run<String>(
  () {
    return 'Done';
  },
);

print(response.data);
```

## Response model

A `ServicesResponse<T>` represents either a successful execution or a failure.

```dart
if (response.isSuccess) {
  print(response.data);
}

if (response.hasFailure) {
  print(response.failure);
}
```

Important distinction:

* `isSuccess` tells whether the task completed successfully.
* `hasFailure` tells whether a failure exists.
* `hasData` tells whether the response contains non-null data.

A response can be successful and still have `hasData == false` when the returned value is `null`.

## Failure model

A `ServicesFailure` contains structured information about a failed task.

```dart
final failure = response.failure;

print(failure?.message);
print(failure?.code);
print(failure?.logs);
print(failure?.error);
print(failure?.stackTrace);
```

`logs` should be used for additional contextual information. The original stack trace is stored separately in `stackTrace`.

## Isolate limitations

`runInIsolate` uses Dart isolates.

The task passed to `runInIsolate` must be compatible with Dart isolate restrictions.

Prefer:

* Top-level functions
* Static functions
* Closures that only capture sendable values

Avoid passing closures that capture:

* Controllers
* Open connections
* Platform objects
* Complex non-sendable objects

## Migration from 1.x to 2.0.0

Version 2.0.0 introduces breaking changes.

#### Flutter dependency removed

The package is now a pure Dart package.

#### `ServicesWorker` is now instantiable

Before:

```dart
final response = await ServicesWorker.execute<int>(
  () => 8 + 8,
);
```

After:

```dart
final worker = ServicesWorker();

final response = await worker.run<int>(
  () => 8 + 8,
);
```

#### `executeInOtherThread` was replaced by `runInIsolate`

Before:

```dart
final response = await ServicesWorker.executeInOtherThread<int>(
  calculate,
);
```

After:

```dart
final worker = ServicesWorker();

final response = await worker.runInIsolate<int>(
  calculate,
);
```

#### `ServicesError` was renamed to `ServicesFailure`

Before:

```dart
final error = response.error;
```

After:

```dart
final failure = response.failure;
```

#### `hasError` was renamed to `hasFailure`

Before:

```dart
if (response.hasError) {
  print(response.error);
}
```

After:

```dart
if (response.hasFailure) {
  print(response.failure);
}
```

## Additional information

If you like this package and find it useful, please give it a like on pub.dev.