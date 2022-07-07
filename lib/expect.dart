part of cake;

class Expect<T> {
  T? expected;
  T? actual;
  ExpectType type;

  Expect(this.type, {required this.actual, required this.expected});
  Expect.equals({required this.actual, required this.expected})
      : type = ExpectType.equals;
  Expect.isNull(this.actual) : type = ExpectType.isNull;
  Expect.isNotNull(this.actual) : type = ExpectType.isNotNull;
  Expect.isType(this.actual) : type = ExpectType.isType;
  Expect.isTrue(this.actual) : type = ExpectType.isTrue;
  Expect.isFalse(this.actual) : type = ExpectType.isFalse;

  _TestResult _run() {
    switch (type) {
      case ExpectType.equals:
        return _equals();
      case ExpectType.isNull:
        return _isNull();
      case ExpectType.isNotNull:
        return _isNotNull();
      case ExpectType.isType:
        return _isType();
      case ExpectType.isTrue:
        return _isTrue();
      case ExpectType.isFalse:
        return _isFalse();
    }
  }

  _TestResult _equals() {
    if (expected == actual) {
      return _TestPass();
    } else {
      return _TestFailure('Equality failed: Expected $expected, got $actual');
    }
  }

  _TestResult _isNull() {
    if (actual == null) {
      return _TestPass();
    } else {
      return _TestFailure('IsNull failed: Expected $actual to be null.');
    }
  }

  _TestResult _isNotNull() {
    if (actual != null) {
      return _TestPass();
    } else {
      return _TestFailure('IsNotNull failed: actual is null.');
    }
  }

  _TestResult _isType() {
    if (actual is T) {
      return _TestPass();
    } else {
      return _TestFailure('IsType failed: Expected $actual to be $T.');
    }
  }

  _TestResult _isTrue() {
    if (actual == true) {
      return _TestPass();
    } else {
      return _TestFailure('IsTrue failed: Expected $actual to be true.');
    }
  }

  _TestResult _isFalse() {
    if (actual == false) {
      return _TestPass();
    } else {
      return _TestFailure('IsFalse failed: Expected $actual to be false.');
    }
  }
}

enum ExpectType {
  equals,
  isNull,
  isNotNull,
  isType,
  isTrue,
  isFalse,
}
