part of 'cake.dart';

class TestOf<ExpectedType> extends _Test<Context<ExpectedType>> {
  TestOf(
    super._title, {
    super.setup,
    super.teardown,
    super.action,
    required super.assertions,
    super.options,
  }) : super(contextBuilder: Context<ExpectedType>.new);

  TestOf.skip(
    super._title, {
    super.setup,
    super.teardown,
    super.action,
    required super.assertions,
    super.options,
  }) : super(
          contextBuilder: Context<ExpectedType>.new,
          skip: true,
        );

  TestOf.stub(super._title)
      : super(
          contextBuilder: Context<ExpectedType>.new,
          assertions: (test) => [],
          skip: true,
        );
}

class Test<TestContext extends Context> extends _Test<TestContext> {
  Test(
    super._title, {
    super.setup,
    super.teardown,
    super.action,
    required super.assertions,
    super.contextBuilder,
    super.options,
  });

  Test.skip(
    super._title, {
    super.setup,
    super.teardown,
    super.action,
    required super.assertions,
    super.contextBuilder,
    super.options,
  }) : super(skip: true);

  Test.stub(
    super._title, {
    super.contextBuilder,
  }) : super(
          assertions: (test) => [],
          skip: true,
        );
}

class _Test<TestContext extends Context> extends Contextual<TestContext> {
  final FutureOr<dynamic> Function(TestContext test)? action;
  final List<Expect<dynamic>> Function(TestContext test) assertions;
  final List<AssertResult> assertFailures = [];

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
    super._title, {
    super.setup,
    super.teardown,
    this.action,
    required this.assertions,
    super.contextBuilder,
    super.options,
    super.skip,
  });

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
    for (AssertResult element in assertFailures) {
      element.report(spacerCount: _parentCount);
    }
  }

  @override
  Future<_TestResult> _getResult(
    TestContext testContext,
    FilterSettings filterSettings,
  ) async {
    // Don't try anything if this is marked as skipped
    if (skip) {
      _result = _TestNeutral(_title, message: 'Skipped');
      return _result!;
    }

    final _TestResult? setupFailure = await _runSetup(testContext);
    if (setupFailure != null) {
      ranSuccessfully = false;
      return setupFailure;
    }

    if (action != null) {
      try {
        final dynamic value = await action!(testContext);
        if (value != null) {
          testContext.actual = value;
        }
      } catch (err) {
        // We want to continue and try to teardown anything we've set up even if it's all haywire at this point
        _result = _TestFailure(_title, 'Failed during action.', err: err);
        ranSuccessfully = false;
      }
    }

    // Don't bother running assertions if we've already come up if this is pass or fail
    if (_result == null) {
      final List<Expect> asserts = assertions(testContext);
      bool hasFailedATest = false;

      for (int i = 0; i < asserts.length; i++) {
        final Expect expect = asserts[i];
        AssertResult assertResult;
        // Skip rest of assertions if an assert has failed already,
        // allowing a bypass with an option flag.
        if (hasFailedATest && options.failOnFirstAssert) {
          assertResult = AssertNeutral(
            message: 'Skipped: Previous assert failed.',
            index: i,
          );
          assertFailures.add(assertResult);
        } else {
          try {
            assertResult = expect.run();
          } catch (err) {
            assertResult = AssertFailure(
              'Failed while running assertions.',
              err: err,
            );
          }

          if (asserts.length > 1) {
            assertResult.index = i;
          }

          if (assertResult is AssertFailure) {
            assertFailures.add(assertResult);
            hasFailedATest = true;
          }
        }
      }

      if (assertFailures.isEmpty) {
        _result = _TestPass(_title);
      } else {
        _result = _TestFailure(_title, 'Assert failed.');
      }
    }

    final _TestResult? teardownFailure = await _runTeardown(testContext);
    if (teardownFailure != null) {
      ranSuccessfully = false;
      return teardownFailure;
    }

    if (_result == null) {
      ranSuccessfully = false;
      _result = _TestFailure(
        _title,
        'Expected result by now! Is this something running asynchronously?',
      );
    }

    // At this point if this hasn't failed, this has ran successfully
    _ranSuccessfully ??= true;
    return _result!;
  }
}
