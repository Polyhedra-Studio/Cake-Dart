part of '../cake.dart';

class MockableFunction extends _MockableBase<dynamic> {
  dynamic _mockValue;

  @override
  dynamic get value => _mockValue;

  @override
  set value(dynamic value) {
    _mockValue = value;
  }

  MockableFunction([super.value]) : _mockValue = value;
}

class MockableFunctionOf<T> extends _MockableBase<T> {
  T _mockValue;

  @override
  T get value => _mockValue;

  @override
  set value(T value) {
    _mockValue = value;
  }

  MockableFunctionOf(super.value) : _mockValue = value;
}

abstract class _MockableBase<T> extends MockBase<T> {
  @override
  T get value;
  @override
  set value(T value);

  final T originalValue;

  bool _throwNextCall = false;
  Exception? _e;

  bool _returnNextCall = false;
  T? __returnNextValue;
  T get _returnNextValue => __returnNextValue!;
  set _returnNextValue(T value) => __returnNextValue = value;

  bool _pause = false;
  bool _pauseRespectsNextCall = false;
  T? __pauseValue;
  T get _pauseValue => __pauseValue ?? value;

  _MockableBase(T value) : originalValue = value;

  /// Reverts all to the original values, so resets the call count, clears call
  /// args, and clears out any next calls.
  @override
  void reset({
    bool clearValue = true,
    bool clearArgs = true,
    bool clearCount = true,
  }) {
    if (clearValue) {
      value = originalValue;
    }

    if (clearCount) {
      callCount = 0;
    }

    if (clearArgs) {
      callArgs.clear();
    }
    _throwNextCall = false;
    _e = null;
    _returnNextCall = false;
    __returnNextValue = null;
  }

  /// Pauses incrementing the call count. Call args will not be recorded. The
  /// default value will be used unless [pausedValue] is provided.
  ///
  /// This ignores throw next call and return next call unless [respectNextCall]
  /// is true.
  @override
  void pause({
    T? pausedValue,
    bool respectNextCall = false,
  }) {
    _pause = true;
    _pauseRespectsNextCall = respectNextCall;
    __pauseValue = pausedValue;
  }

  /// Resumes incrementing the call count after pausing.
  @override
  void resume() {
    _pause = false;
    _pauseRespectsNextCall = false;
    __pauseValue = null;
  }

  /// The next time this function is called, throw [e]. If [e] is not provided,
  /// this will throw 'Mocked exception'.
  void throwNextCall([Exception? e]) {
    _throwNextCall = true;
    _e = e;
  }

  /// The next time this function is called, return [value]. It will return
  /// to the original value after the next call is made.
  void returnNextCall(T value) {
    _returnNextCall = true;
    _returnNextValue = value;
  }

  /// Returns the mocked value. [args] and [namedArgs] should be provided if
  /// the mocked function takes arguments.
  ///
  /// Example:
  /// ```dart
  /// class MockClass extends ClassToMock {
  ///   final MockableFunctionOf<String> mock = MockableFunctionOf<String>('foobar');
  ///
  ///   @override
  ///   String mockedFunction(String foo, {String? bar}) {
  ///     return mock.call(args: [foo], namedArgs: {'bar': bar});
  ///   }
  /// }
  /// ```
  @override
  T call([List<dynamic>? args, Map<String, dynamic>? namedArgs]) {
    if (_pause) {
      if (!_pauseRespectsNextCall) {
        return _pauseValue;
      }

      // Intentionally continue if respectNextCall is true
    } else {
      callArgs.add(CallArgs(args, namedArgs));
      callCount++;
    }

    if (_throwNextCall) {
      _throwNextCall = false;
      if (_e != null) {
        _e = null;
        throw _e!;
      }
      throw 'Mocked exception';
    }

    if (_returnNextCall) {
      _returnNextCall = false;
      final T nextValue = _returnNextValue;
      __returnNextValue = null;
      return nextValue;
    }

    return value;
  }
}
