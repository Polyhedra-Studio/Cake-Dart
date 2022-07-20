import 'package:cake/cake.dart';

void main() {
  TestRunner('All of these should fail in various ways', [
    Test(
      'Should report multiple failures',
      assertions: (test) => [
        Expect.equals(actual: true, expected: false),
        Expect.isTrue(true), // This one is meant to pass
        Expect.isFalse(true),
        Expect.isTrue(false),
      ],
    )
  ]);
}
