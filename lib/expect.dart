import 'test_failure.dart';
import 'test_pass.dart';
import 'test_result.dart';

class Expect<T> {
  T? expected;
  T? actual;
  ExpectType type;

  Expect(this.type, {required this.expected, required this.actual});

  TestResult run() {
    switch (type) {
      case ExpectType.equals:
        return _equals();
    }
  }

  TestResult _equals() {
    if (expected == actual) {
      return TestPass();
    } else {
      return TestFailure('Equality failed: Expected $expected, got $actual');
    }
  }
}

enum ExpectType {
  equals;
}
