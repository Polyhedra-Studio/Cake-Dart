import 'package:cake/cake.dart';

void main() {
  TestRunnerDefault('All of these should fail in various ways', [
    Test(
      'Should report multiple failures',
      assertions: (test) => [
        Expect.equals(actual: true, expected: false),
        Expect.isTrue(true), // This one is meant to pass
        Expect.isFalse(true),
        Expect.isTrue(false),
      ],
      options: const TestOptions(failOnFirstExpect: false),
    ),
    Test(
      'Should report only one failure by default',
      assertions: (test) => [
        Expect.equals(actual: true, expected: false),
        Expect.isTrue(true), // This one is meant to pass
        Expect.isFalse(true), // This is a failure, but shouldn't be run
        Expect.isTrue(false), // This is also a failure, but shouldn't be run
      ],
    ),
    Test(
      'Should report only one failure when failOnFirstExpect is true',
      assertions: (test) => [
        Expect.equals(actual: true, expected: false),
        Expect.isTrue(true), // This one is meant to pass
        Expect.isFalse(true), // This is a failure, but shouldn't be run
        Expect.isTrue(false), // This is also a failure, but shouldn't be run
      ],
      options: const TestOptions(failOnFirstExpect: true),
    )
  ]);
}
