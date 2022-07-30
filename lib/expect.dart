part of cake;

class Expect<T> {
  final T? _expected;
  final T? _actual;
  final ExpectType type;

  Expect(this.type, {required T? actual, required T? expected})
      : _actual = actual,
        _expected = expected;
  Expect.equals({required T? actual, required T? expected})
      : type = ExpectType.equals,
        _actual = actual,
        _expected = expected;
  Expect.isNotEqual({required T? actual, required T? notExpected})
      : type = ExpectType.isNotEqual,
        _actual = actual,
        _expected = notExpected;
  Expect.isNull(T? actual)
      : type = ExpectType.isNull,
        _actual = actual,
        _expected = null;
  Expect.isNotNull(T? actual)
      : type = ExpectType.isNotNull,
        _actual = actual,
        _expected = null;
  Expect.isType(dynamic actual)
      : type = ExpectType.isType,
        _actual = actual,
        _expected = null;
  Expect.isTrue(T? actual)
      : type = ExpectType.isTrue,
        _actual = actual,
        _expected = null;
  Expect.isFalse(T? actual)
      : type = ExpectType.isFalse,
        _actual = actual,
        _expected = null;

  _TestResult _run() {
    switch (type) {
      case ExpectType.equals:
        return _equals();
      case ExpectType.isNotEqual:
        return _isNotEqual();
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
    if (_expected == _actual) {
      return _TestPass();
    } else {
      return _TestFailure('Equality failed: Expected $_expected, got $_actual');
    }
  }

  _TestResult _isNotEqual() {
    // For the sake of verbosity, _expected should really be called _notExpected
    // but there's no need to create a new variable just for that.
    if (_expected != _actual) {
      return _TestPass();
    } else {
      return _TestFailure(
          'Inequality failed: Expected $_actual to not equal $_expected');
    }
  }

  _TestResult _isNull() {
    if (_actual == null) {
      return _TestPass();
    } else {
      return _TestFailure('IsNull failed: Expected $_actual to be null.');
    }
  }

  _TestResult _isNotNull() {
    if (_actual != null) {
      return _TestPass();
    } else {
      return _TestFailure('IsNotNull failed: _actual is null.');
    }
  }

  _TestResult _isType() {
    if (_actual is T) {
      return _TestPass();
    } else {
      return _TestFailure('IsType failed: Expected $_actual to be $T.');
    }
  }

  _TestResult _isTrue() {
    if (_actual == true) {
      return _TestPass();
    } else {
      return _TestFailure('IsTrue failed: Expected $_actual to be true.');
    }
  }

  _TestResult _isFalse() {
    if (_actual == false) {
      return _TestPass();
    } else {
      return _TestFailure('IsFalse failed: Expected $_actual to be false.');
    }
  }
}

enum ExpectType {
  equals,
  isNotEqual,
  isNull,
  isNotNull,
  isType,
  isTrue,
  isFalse,
}
