import 'test_failure.dart';
import 'test_pass.dart';
import 'test_result.dart';

class Expect<T> {
  T? expected;
  T? actual;
  ExpectType type;

  Expect(this.type, {required this.expected, required this.actual});
  Expect.equals({required this.expected, required this.actual})
      : type = ExpectType.equals;
  Expect.isNull({required this.actual}) : type = ExpectType.isNull;
  Expect.isNotNull({required this.actual}) : type = ExpectType.isNotNull;
  Expect.isType({required this.actual}) : type = ExpectType.isType;

  TestResult run() {
    switch (type) {
      case ExpectType.equals:
        return _equals();
      case ExpectType.isNull:
        return _isNull();
      case ExpectType.isNotNull:
        return _isNotNull();
      case ExpectType.isType:
        return _isType();
    }
  }

  TestResult _equals() {
    if (expected == actual) {
      return TestPass();
    } else {
      return TestFailure('Equality failed: Expected $expected, got $actual');
    }
  }

  TestResult _isNull() {
    if (actual == null) {
      return TestPass();
    } else {
      return TestFailure('IsNull failed: Expected $actual to be null.');
    }
  }

  TestResult _isNotNull() {
    if (actual != null) {
      return TestPass();
    } else {
      return TestFailure('IsNotNull failed: actual is null.');
    }
  }

  TestResult _isType() {
    if (actual is T) {
      return TestPass();
    } else {
      return TestFailure('IsType failed: Expected $actual to be $T');
    }
  }
}

enum ExpectType {
  equals,
  isNull,
  isNotNull,
  isType,
}
