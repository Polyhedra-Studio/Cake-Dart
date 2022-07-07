part of cake;

class Test<T> extends _Test<T, Context<T>> {
  Test(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(Context<T> test)? setup,
    FutureOr<void> Function(Context<T> test)? teardown,
    FutureOr<dynamic> Function(Context<T> test)? action,
    List<Expect<dynamic>> Function(Context<T> test)? assertions,
  }) : super(
          title,
          expected: expected,
          actual: actual,
          setup: setup,
          teardown: teardown,
          action: action,
          assertions: assertions,
        );
}

class TestWithContext<T, C extends Context<T>> extends _Test<T, C> {
  TestWithContext(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(C test)? setup,
    FutureOr<void> Function(C test)? teardown,
    FutureOr<dynamic> Function(C test)? action,
    List<Expect> Function(C test)? assertions,
    C Function()? contextBuilder,
  }) : super.context(
          title,
          expected: expected,
          actual: actual,
          setup: setup,
          teardown: teardown,
          action: action,
          assertions: assertions,
          contextBuilder: contextBuilder,
        );
}

class _Test<T, C extends Context<T>> extends Contextual<T, C> {
  final FutureOr<dynamic> Function(Context<T> test)? action;
  final FutureOr<dynamic> Function(C test)? actionWithContext;
  List<Expect<dynamic>> Function(Context<T> test)? assertions;
  List<Expect<dynamic>> Function(C test)? assertionsWithContext;
  final List<_TestFailure> assertFailures = [];
  final T? _actual;
  final T? _expected;

  _Test(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(Context<T> test)? setup,
    FutureOr<void> Function(Context<T> test)? teardown,
    this.action,
    this.assertions,
  })  : actionWithContext = null,
        assertionsWithContext = null,
        _actual = actual,
        _expected = expected,
        super(title,
            setup: setup,
            teardown: teardown,
            simpleContext: Context.test(
              expected: expected,
              actual: actual,
            ));

  _Test.context(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(C test)? setup,
    FutureOr<void> Function(C test)? teardown,
    FutureOr<dynamic> Function(C test)? action,
    List<Expect> Function(C test)? assertions,
    C Function()? contextBuilder,
  })  : actionWithContext = action,
        assertionsWithContext = assertions,
        action = null,
        assertions = null,
        _actual = actual,
        _expected = expected,
        super.context(
          title,
          setupWithContext: setup,
          teardownWithContext: teardown,
          contextBuilder: contextBuilder,
          context: () {
            if (contextBuilder != null) {
              C context = contextBuilder();
              context.actual = actual;
              context.expected = expected;
              return context;
            }
            return null;
          }(),
        );

  @override
  void _assignParent(dynamic parentContextBuilder) {
    super._assignParent(parentContextBuilder);
    if (_contextBuilder != null) {
      try {
        C newContext = _contextBuilder!();
        newContext.actual = _actual;
        newContext.expected = _expected;
        _context = newContext;
      } catch (err) {
        throw 'Cake Test Runner: Issue setting up test "$_title". Test context is getting a different type than expected. Check parent groups and test runners.';
      }
    }
  }

  @override
  void report() {
    _result!.report(spacerCount: _parentCount);
    for (_TestFailure element in assertFailures) {
      element.report(spacerCount: _parentCount);
    }
  }

  List<Expect<T>> _defaultAssertion(Context<T> context) {
    return [
      Expect<T>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }

  List<Expect<T>> _defaultAssertionWithContext(C context) {
    return [
      Expect<T>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }

  @override
  Future<_TestResult> _getResult(Context testContext) async {
    // Assign parent context on top of current
    simpleContext!.applyParentContext(testContext);

    _TestResult? setupFailure = await _runSetup(simpleContext!);
    if (setupFailure != null) {
      return setupFailure;
    }

    if (action != null) {
      try {
        dynamic value = await action!(simpleContext!);
        if (value is T) {
          simpleContext!.actual = await action!(simpleContext!);
        }
      } catch (err) {
        // We want to try to teardown anything we've set up even if it's all haywire at this point
        _result = _TestFailure.result(_title, 'Failed during action', err: err);
      }
    }

    // Don't bother running assertions if we've already come up if this is pass or fail
    if (_result == null) {
      assertions ??= _defaultAssertion;
      List<Expect> asserts = assertions!(simpleContext!);

      for (Expect expect in asserts) {
        _TestResult assertResult = expect._run();
        if (assertResult is _TestFailure) {
          assertFailures.add(assertResult);
        }
      }

      if (assertFailures.isEmpty) {
        _result = _TestPass.result(_title);
      } else {
        _result = _TestFailure.result(_title, 'Assert failed');
      }
    }

    _TestResult? teardownFailure = await _runTeardown(simpleContext!);
    if (teardownFailure != null) {
      return teardownFailure;
    }
    _result ??= _TestNeutral.result(_title,
        message:
            'Expected result by now! Is this there something running asynchronously?');
    return _result!;
  }

  @override
  Future<_TestResult> _getResultWithContext(C testContext) async {
    // Assign parent context on top of current
    _context!.applyParentContext(testContext);

    _TestResult? setupFailure = await _runSetupWithContext(_context!);
    if (setupFailure != null) {
      return setupFailure;
    }

    if (actionWithContext != null) {
      try {
        dynamic value = await actionWithContext!(_context!);
        if (value is T) {
          _context!.actual = value;
        }
      } catch (err) {
        // We want to try to teardown anything we've set up even if it's all haywire at this point
        _result = _TestFailure.result(_title, 'Failed during action', err: err);
      }
    }

    // Don't bother running assertions if we've already come up if this is pass or fail
    if (_result == null) {
      assertionsWithContext ??= _defaultAssertionWithContext;
      List<Expect> asserts = assertionsWithContext!(_context!);

      for (Expect expect in asserts) {
        _TestResult assertResult = expect._run();
        if (assertResult is _TestFailure) {
          assertFailures.add(assertResult);
        }
      }

      if (assertFailures.isEmpty) {
        _result = _TestPass.result(_title);
      } else {
        _result = _TestFailure.result(_title, 'Assert failed');
      }
    }

    _TestResult? teardownFailure = await _runTeardownWithContext(_context!);
    if (teardownFailure != null) {
      return teardownFailure;
    }
    _result ??= _TestNeutral.result(_title,
        message:
            'Expected result by now! Is this there something running asynchronously?');
    return _result!;
  }
}
