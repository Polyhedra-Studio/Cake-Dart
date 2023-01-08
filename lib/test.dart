part of cake;

class Test<ExpectedType> extends _Test<ExpectedType, Context<ExpectedType>> {
  Test(
    String title, {
    FutureOr<void> Function(Context<ExpectedType> test)? setup,
    FutureOr<void> Function(Context<ExpectedType> test)? teardown,
    FutureOr<dynamic> Function(Context<ExpectedType> test)? action,
    required List<Expect<dynamic>> Function(Context<ExpectedType> test)
        assertions,
    TestOptions? options,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          action: action,
          assertions: assertions,
          options: options,
        );

  Test.stub(String title) : super(title, assertions: (test) => []);
}

class TestWithContext<ExpectedType, TestContext extends Context<ExpectedType>>
    extends _Test<ExpectedType, TestContext> {
  TestWithContext(
    String title, {
    FutureOr<void> Function(TestContext test)? setup,
    FutureOr<void> Function(TestContext test)? teardown,
    FutureOr<dynamic> Function(TestContext test)? action,
    required List<Expect> Function(TestContext test) assertions,
    TestContext Function()? contextBuilder,
    TestOptions? options,
  }) : super.context(
          title,
          setup: setup,
          teardown: teardown,
          action: action,
          assertions: assertions,
          contextBuilder: contextBuilder,
          options: options,
        );

  TestWithContext.stub(
    String title, {
    TestContext Function()? contextBuilder,
  }) : super.context(title, assertions: (test) => []);
}

class _Test<ExpectedType, TestContext extends Context<ExpectedType>>
    extends Contextual<ExpectedType, TestContext> {
  final FutureOr<dynamic> Function(Context<ExpectedType> test)? action;
  final FutureOr<dynamic> Function(TestContext test)? actionWithContext;
  List<Expect<dynamic>> Function(Context<ExpectedType> test)? assertions;
  List<Expect<dynamic>> Function(TestContext test)? assertionsWithContext;
  final List<_TestResult> assertFailures = [];

  TestOptions get options => _options ?? const TestOptions();

  bool? _ranSuccessfully;
  bool? get ranSuccessfully => _ranSuccessfully;

  set ranSuccessfully(bool? value) {
    // Once this has failed, don't allow it to recover
    if (_ranSuccessfully == false) {
      return;
    }
    _ranSuccessfully = value;
  }

  _Test(
    String title, {
    FutureOr<void> Function(Context<ExpectedType> test)? setup,
    FutureOr<void> Function(Context<ExpectedType> test)? teardown,
    this.action,
    required this.assertions,
    TestOptions? options,
  })  : actionWithContext = null,
        assertionsWithContext = null,
        super(
          title,
          setup: setup,
          teardown: teardown,
          options: options,
          simpleContext: Context<ExpectedType>(),
        );

  _Test.context(
    String title, {
    FutureOr<void> Function(TestContext test)? setup,
    FutureOr<void> Function(TestContext test)? teardown,
    FutureOr<dynamic> Function(TestContext test)? action,
    required List<Expect> Function(TestContext test) assertions,
    TestContext Function()? contextBuilder,
    TestOptions? options,
  })  : actionWithContext = action,
        assertionsWithContext = assertions,
        action = null,
        assertions = null,
        super.context(
          title,
          setupWithContext: setup,
          teardownWithContext: teardown,
          contextBuilder: contextBuilder,
          context: () {
            if (contextBuilder != null) {
              return contextBuilder();
            }
            return null;
          }(),
          options: options,
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
    for (_TestResult element in assertFailures) {
      element.report(spacerCount: _parentCount);
    }
  }

  @override
  void _assignParent(dynamic parentContextBuilder, TestOptions? parentOptions) {
    super._assignParent(parentContextBuilder, parentOptions);
    if (_contextBuilder != null) {
      try {
        _context = _contextBuilder!();
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
      bool hasFailedATest = false;

      for (int i = 0; i < asserts.length; i++) {
        Expect expect = asserts[i];
        _TestResult assertResult;
        // Skip rest of assertions if an assert has failed already,
        // allowing a bypass with an option flag.
        if (hasFailedATest && options.failOnFirstAssert) {
          assertResult = _TestNeutral.result(
            '[#$i] Skipped',
            message: 'Previous assert failed.',
          );
          assertFailures.add(assertResult);
        } else {
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
            hasFailedATest = true;
          }
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
