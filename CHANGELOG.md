# Changelog

## 2.0.0
* BREAKING: Removed Flutter dependency and converted the package into a pure Dart package.
* BREAKING: Removed Flutter-specific package configuration from `pubspec.yaml`.
* BREAKING: Changed `ServicesWorker` from a static utility-style API to an instantiable `final class`.
* BREAKING: Replaced `ServicesWorker.execute` with `ServicesWorker().run`.
* BREAKING: Replaced `ServicesWorker.executeInOtherThread` with `ServicesWorker().runInIsolate`.
* BREAKING: Renamed `ServicesError` to `ServicesFailure`.
* BREAKING: Renamed `ServicesResponse.error` to `ServicesResponse.failure`.
* BREAKING: Renamed `ServicesResponse.hasError` to `ServicesResponse.hasFailure`.
* BREAKING: Renamed `ServicesResponse.error` property to `ServicesResponse.failure`.
* BREAKING: Reworked failure mapping to preserve the original error object and stack trace separately.
* BREAKING: Removed custom failure data payload from the failure model.
* BREAKING: Updated no-result generic guidance to prefer `Null` instead of `void`.
* FEAT: Added a shared `servicesWorker` convenience instance for users that do not need dependency injection.
* FIX: Preserved original error messages instead of using only runtime type names.
* FIX: Preserved original `ServicesException.stackTrace` when already provided.
* FIX: Added the caught stack trace to mapped failures only when a `ServicesException` does not already contain one.
* FIX: Removed stack trace duplication from failure logs.
* FIX: Clarified successful nullable responses by keeping `isSuccess` separate from `hasData`.
* REFACTOR: Reworked `ServicesFailure` to store `message`, `code`, `logs`, `error`, and `stackTrace`.
* REFACTOR: Kept `ServicesException` as a structured throwable failure by extending `ServicesFailure` and implementing `Exception`.
* REFACTOR: Moved from thread-oriented naming to Dart isolate-oriented naming.
* REFACTOR: Improved `copyWith` and `copyWithAdditionalLogs` behavior for `ServicesFailure`.
* DOCS: Reworked and expanded public API documentation.
* DOCS: Added library-level documentation for pub.dev API coverage.
* DOCS: Updated documentation to describe `run`, `runInIsolate`, nullable results, failure mapping, and isolate restrictions.
* DOCS: Corrected English wording in package documentation.
* TEST: Added and updated tests for the revised 2.0.0 API.
* TEST: Added coverage for sync execution, async execution, isolate execution, nullable successful responses, common exceptions, `ServicesException`, custom failure mapping, and stack trace preservation.

## 1.0.6
* Corrigindo erro no exemplo do file README.md

## 1.0.5
* Update: stopped using compute() and now uses Isolate.run()

## 1.0.4
* FEAT: update dependency constraints to sdk: '>=2.18.1 <4.0.0' flutter: '>=3.3.0'
* FEAT: update libraries to be compatible with Flutter 3.10.0

## 1.0.3
Some adsjustment made on base error class

## 1.0.2
Services Worker is a abstract class that assists with the execution of asynchronous tasks.