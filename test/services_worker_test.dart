import 'package:flutter_test/flutter_test.dart';

import 'package:services_worker/services_worker.dart';

void main() {
  test('adds one to input values', () {
    expect(ServicesWorker.execute(() => null), null);

    expect(ServicesWorker.execute(() async {
      await Future.delayed(const Duration(milliseconds: 1000));

      return null;
    }), null);
  });
}
