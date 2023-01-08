part of cake;

class Test<ExpectedType> extends _Test<ExpectedType, Context<ExpectedType>> {
  Test(
    String title, {
    ExpectedType? expected,
    ExpectedType? actual,
    FutureOr<void> Function(Context<ExpectedType> test)? setup,
    FutureOr<void> Function(Context<ExpectedType> test)? teardown,
    FutureOr<dynamic> Function(Context<ExpectedType> test)? action,
    List<Expect<dynamic>> Function(Context<ExpectedType> test)? assertions,
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

class TestWithContext<ExpectedType, TestContext extends Context<ExpectedType>>
    extends _Test<ExpectedType, TestContext> {
  TestWithContext(
    String title, {
    ExpectedType? expected,
    ExpectedType? actual,
    FutureOr<void> Function(TestContext test)? setup,
    FutureOr<void> Function(TestContext test)? teardown,
    FutureOr<dynamic> Function(TestContext test)? action,
    List<Expect> Function(TestContext test)? assertions,
    TestContext Function()? contextBuilder,
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

class _Test<ExpectedType, TestContext extends Context<ExpectedType>>
    extends Contextual<ExpectedType, TestContext> {
  final FutureOr<dynamic> Function(Context<ExpectedType> test)? action;
  final FutureOr<dynamic> Function(TestContext test)? actionWithContext;
  List<Expect<dynamic>> Function(Context<ExpectedType> test)? assertions;
  List<Expect<dynamic>> Function(TestContext test)? assertionsWithContext;
  final List<_TestFailure> assertFailures = [];
  final ExpectedType? _actual;
  final ExpectedType? _expected;
  bool? _ranSuccessfully;

  bool? get ranSuccessfully {
    return _ranSuccessfully;
  }

  set ranSuccessfully(bool? value) {
    // Once this has failed, don't allow it to recover
    if (_ranSuccessfully == false) {
      return;
    }
    _ranSuccessfully = value;
  }

  _Test(
    String title, {
    ExpectedType? expected,
    ExpectedType? actual,
    FutureOr<void> Function(Context<ExpectedType> test)? setup,
    FutureOr<void> Function(Context<ExpectedType> test)? teardown,
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
    ExpectedType? expected,
    ExpectedType? actual,
    FutureOr<void> Function(TestContext test)? setup,
    FutureOr<void> Function(TestContext test)? teardown,
    FutureOr<dynamic> Function(TestContext test)? action,
    List<Expect> Function(TestContext test)? assertions,
    TestContext Function()? contextBuilder,
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
              TestContext context = contextBuilder();
              context.actual = actual;
              context.expected = expected;
              return context;
            }
            return null;
          }(),
        );

  @override
  bool _shouldRunWithFilter(FilterSettings filterSettings) {
    if (filterSettings.hasTestSearchFor) {
      return filterSettings.testSearchFor == _title;
    }
    if (filterSettings.hasTestFilterTerm) {
      return _title.contains(filterSettings.testFilterTerm!);
    }
    if (filterSettings.hasGeneralSearchTerm) {
      return _title.contains(filterSettings.generalSearchTerm!);
    }

    // No applicable filter - this should run
    return true;
  }

  @override
  void report(FilterSettings filterSettings) {
    _result!.report(spacerCount: _parentCount);
    for (_TestFailure element in assertFailures) {
      element.report(spacerCount: _parentCount);
    }
  }

  @override
  void _assignParent(dynamic parentContextBuilder) {
    super._assignParent(parentContextBuilder);
    if (_contextBuilder != null) {
      try {
        TestContext newContext = _contextBuilder!();
        newContext.actual = _actual;
        newContext.expected = _expected;
        _context = newContext;
      } catch (err) {
        throw 'Cake Test Runner: Issue setting up test "$_title". Test context is getting a different type than expected. Check parent groups and test runners.';
      }
    }
  }

  List<Expect<ExpectedType>> _defaultAssertion(Context<ExpectedType> context) {
    return [
      Expect<ExpectedType>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }

  List<Expect<ExpectedType>> _defaultAssertionWithContext(TestContext context) {
    return [
      Expect<ExpectedType>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }

  @override
  Future<_TestResult> _getResult(
      Context testContext, FilterSettings filterSettings) async {
    assertions ??= _defaultAssertion;
    return _getResultShared(
      assignContextFn: () => simpleContext!.applyParentContext(testContext),
      setupFn: () => _runSetup(simpleContext!),
      actionFn: () => action!(simpleContext!),
      teardownFn: () => _runSetup(simpleContext!),
      assertionsFn: () => assertions!(simpleContext!),
      shouldRunAction: action != null,
    );
  }

  @override
  Future<_TestResult> _getResultWithContext(
      TestContext testContext, FilterSettings filterSettings) async {
    assertionsWithContext ??= _defaultAssertionWithContext;
    return _getResultShared(
        assignContextFn: () => _context!.applyParentContext(testContext),
        setupFn: () => _runSetupWithContext(_context!),
        actionFn: () => actionWithContext!(_context!),
        teardownFn: () => _runTeardownWithContext(_context!),
        assertionsFn: () => assertionsWithContext!(_context!),
        shouldRunAction: actionWithContext != null);
  }

  Future<_TestResult> _getResultShared({
    required void Function() assignContextFn,
    required Future<_TestResult?> Function() setupFn,
    required FutureOr<dynamic> Function() actionFn,
    required Future<_TestResult?> Function() teardownFn,
    required List<Expect> Function() assertionsFn,
    required bool shouldRunAction,
  }) async {
    // Assign parent context on top of current
    try {
      assignContextFn();
    } catch (err) {
      _ranSuccessfully = false;
      _result = _TestFailure.result(_title, 'Failed trying to assign context',
          err: err);
      return _result!;
    }

    _TestResult? setupFailure = await setupFn();
    if (setupFailure != null) {
      ranSuccessfully = false;
      return setupFailure;
    }

    if (shouldRunAction) {
      try {
        dynamic value = await actionFn();
        if (value is ExpectedType) {
          if (_hasCustomContext) {
            _context!.actual = value;
          } else {
            simpleContext!.actual = value;
          }
        }
      } catch (err) {
        // We want to continue and try to teardown anything we've set up even if it's all haywire at this point
        _result = _TestFailure.result(_title, 'Failed during action', err: err);
        ranSuccessfully = false;
      }
    }

    // Don't bother running assertions if we've already come up if this is pass or fail
    if (_result == null) {
      List<Expect> asserts = assertionsFn();

      for (int i = 0; i < asserts.length; i++) {
        Expect expect = asserts[i];
        _TestResult assertResult;

        try {
          assertResult = expect._run();
        } catch (err) {
          assertResult = _TestFailure.result(
              _title, 'Failed while running assertions',
              err: err);
        }

        if (assertResult is _TestFailure) {
          if (asserts.length > 1) {
            assertResult.errorIndex = i;
          }
          assertFailures.add(assertResult);
        }
      }

      if (assertFailures.isEmpty) {
        _result = _TestPass.result(_title);
      } else {
        _result = _TestFailure.result(_title, 'Assert failed');
      }
    }

    _TestResult? teardownFailure = await teardownFn();
    if (teardownFailure != null) {
      ranSuccessfully = false;
      return teardownFailure;
    }

    if (_result == null) {
      ranSuccessfully = false;
      _result = _TestNeutral.result(_title,
          message:
              'Expected result by now! Is this something running asynchronously?');
    }

    // At this point if this hasn't failed, this has ran successfully
    _ranSuccessfully ??= true;
    return _result!;
  }
}
