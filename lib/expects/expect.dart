part of '../cake.dart';

class Expect<ExpectedType> {
  final ExpectedType? _expected;
  final ExpectedType? _actual;

  Expect({
    required ExpectedType? actual,
    required ExpectedType? expected,
  })  : _actual = actual,
        _expected = expected;

  /// Checks if actual == expected
  ///
  /// Synonym for [Expect.isEqual]
  factory Expect.equals({
    required ExpectedType? actual,
    required ExpectedType? expected,
  }) {
    return _ExpectEquals(actual: actual, expected: expected);
  }

  /// Checks if actual == expected
  ///
  /// Synonym for [Expect.equals]
  factory Expect.isEqual({
    required ExpectedType? actual,
    required ExpectedType? expected,
  }) {
    return _ExpectEquals(actual: actual, expected: expected);
  }

  /// Checks if actual != expected
  factory Expect.isNotEqual({
    required ExpectedType? actual,
    required ExpectedType? notExpected,
  }) {
    return _ExpectIsNotEqual(actual: actual, expected: notExpected);
  }

  /// Checks if actual is null
  factory Expect.isNull(ExpectedType? actual) {
    return _ExpectIsNull(actual: actual);
  }

  /// Checks if actual is not null
  factory Expect.isNotNull(ExpectedType? actual) {
    return _ExpectIsNotNull(actual: actual);
  }

  /// Checks if actual is of type
  factory Expect.isType(dynamic actual) {
    return _ExpectIsType(actual: actual);
  }

  /// Checks if actual is true
  factory Expect.isTrue(ExpectedType? actual) {
    return _ExpectIsTrue(actual: actual);
  }

  /// Checks if actual is false
  factory Expect.isFalse(ExpectedType? actual) {
    return _ExpectIsFalse(actual: actual);
  }

  AssertResult run() {
    return AssertNeutral();
  }
}

class _ExpectEquals<ExpectedType> extends Expect<ExpectedType> {
  _ExpectEquals({
    required super.actual,
    required super.expected,
  });

  @override
  AssertResult run() {
    if (_expected == _actual) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Equality failed: Expected $_expected, got $_actual.',
      );
    }
  }
}

class _ExpectIsNotEqual<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsNotEqual({
    required super.actual,
    required super.expected,
  });

  @override
  AssertResult run() {
    // For the sake of verbosity, _expected should really be called _notExpected
    // but there's no need to create a new variable just for that.
    if (_expected != _actual) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Inequality failed: Expected $_actual to not equal $_expected.',
      );
    }
  }
}

class _ExpectIsNull<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsNull({
    required super.actual,
  }) : super(expected: null);

  @override
  AssertResult run() {
    if (_actual == null) {
      return AssertPass();
    } else {
      return AssertFailure('IsNull failed: Expected $_actual to be null.');
    }
  }
}

class _ExpectIsNotNull<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsNotNull({
    required super.actual,
  }) : super(expected: null);

  @override
  AssertResult run() {
    if (_actual != null) {
      return AssertPass();
    } else {
      return AssertFailure('IsNotNull failed: $_actual is null.');
    }
  }
}

class _ExpectIsType<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsType({
    required super.actual,
  }) : super(expected: null);

  @override
  AssertResult run() {
    if (_actual is ExpectedType) {
      return AssertPass();
    } else {
      return AssertFailure(
        'IsType failed: Expected $_actual to be $ExpectedType.',
      );
    }
  }
}

class _ExpectIsTrue<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsTrue({
    required super.actual,
  }) : super(expected: null);

  @override
  AssertResult run() {
    if (_actual == true) {
      return AssertPass();
    } else {
      return AssertFailure('IsTrue failed: Expected $_actual to be true.');
    }
  }
}

class _ExpectIsFalse<ExpectedType> extends Expect<ExpectedType> {
  _ExpectIsFalse({
    required super.actual,
  }) : super(expected: null);

  @override
  AssertResult run() {
    if (_actual == false) {
      return AssertPass();
    } else {
      return AssertFailure('IsFalse failed: Expected $_actual to be false.');
    }
  }
}
