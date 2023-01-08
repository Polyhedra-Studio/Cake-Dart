part of cake;

abstract class Contextual<ExpectedType,
    ContextualContext extends Context<ExpectedType>> {
  final String _title;
  final FutureOr<void> Function(Context<ExpectedType> test)? setup;
  final FutureOr<void> Function(ContextualContext test)? setupWithContext;
  final FutureOr<void> Function(Context<ExpectedType> test)? teardown;
  final FutureOr<void> Function(ContextualContext test)? teardownWithContext;

  final Context<ExpectedType>? simpleContext;
  // For some reason dart's not picking up that this is getting changed in a extended class
  // ignore: prefer_final_fields
  ContextualContext? _context;

  ContextualContext Function()? _contextBuilder;
  int _parentCount = 0;
  _TestResult? _result;
  final List<_TestResult> _messages = [];
  bool _hasCustomContext = false;

  Contextual(
    this._title, {
    this.setup,
    this.teardown,
    this.simpleContext,
  })  : _context = null,
        setupWithContext = null,
        teardownWithContext = null,
        _contextBuilder = null;

  Contextual.context(
    this._title, {
    required this.setupWithContext,
    required this.teardownWithContext,
    ContextualContext Function()? contextBuilder,
    required ContextualContext? context,
  })  : _hasCustomContext = true,
        _context = context,
        _contextBuilder = contextBuilder,
        setup = null,
        teardown = null,
        simpleContext = null;

  void report(FilterSettings filterSettings);
  bool _shouldRunWithFilter(FilterSettings filterSettings) => false;

  Future<_TestResult> _getResult(
      Context<ExpectedType> testContext, FilterSettings filterSettings);
  Future<_TestResult> _getResultWithContext(
      ContextualContext testContext, FilterSettings filterSettings);

  Future<_TestResult> _run(
      Context<ExpectedType> testContext, FilterSettings filterSettings) async {
    _result = await _getResult(testContext, filterSettings);
    return _result!;
  }

  Future<_TestResult> _runWithContext(
      ContextualContext testContext, FilterSettings filterSettings) async {
    _result = await _getResultWithContext(testContext, filterSettings);
    return _result!;
  }

  void _assignParent(dynamic parentContextBuilder) {
    _parentCount++;
    // Assign and inherit the parent contextBuilder
    if (parentContextBuilder != null && _contextBuilder == null) {
      _contextBuilder = parentContextBuilder;
      _hasCustomContext = true;
    }
  }

  Future<_TestResult?> _runSetup(Context<ExpectedType> simpleContext) async {
    if (setup != null) {
      try {
        await setup!(simpleContext);
      } catch (err) {
        return _TestFailure.result(_title, 'Failed during setup', err: err);
      }
    }

    return null;
  }

  Future<_TestResult?> _runSetupWithContext(ContextualContext context) async {
    if (setupWithContext != null) {
      try {
        await setupWithContext!(context);
      } catch (err) {
        return _TestFailure.result(_title, 'Failed during setup', err: err);
      }
    }
    return null;
  }

  Future<_TestResult?> _runTeardown(Context<ExpectedType> testContext) async {
    if (teardown != null) {
      try {
        await teardown!(testContext);
      } catch (err) {
        if (_result is _TestPass) {
          return _TestFailure.result(
              _title, 'Tests passed, but failed during teardown.',
              err: err);
        } else {
          _messages.add(
              _TestFailure.result(_title, 'Failed during teardown', err: err));
        }
      }
    }
    return null;
  }

  Future<_TestResult?> _runTeardownWithContext(
      ContextualContext testContext) async {
    if (teardownWithContext != null) {
      try {
        await teardownWithContext!(testContext);
      } catch (err) {
        if (_result is _TestPass) {
          return _TestFailure.result(
              _title, 'Tests passed, but failed during teardown.',
              err: err);
        } else {
          _messages.add(
              _TestFailure.result(_title, 'Failed during teardown', err: err));
        }
      }
    }
    return null;
  }

  Context<ExpectedType> _translateContextSimple(Context oldContext) {
    return Context<ExpectedType>.deepCopy(oldContext);
  }

  ContextualContext _translateContext(Context oldContext) {
    if (_contextBuilder == null) {
      String errorMessage =
          "No context found for '$_title'! Did you remember to include a context builder for this or in one of it's parents?";
      _criticalFailure(errorMessage);
      throw errorMessage;
    }
    return _contextBuilder!()..copy(oldContext);
  }

  /*
   * Used for reporting critical test-stopping issues
   */
  void _criticalFailure(String errorMessage) {
    _result = _TestFailure.result(_title, errorMessage);
  }

  /*
   * Used for reporting when this test cannot run due to a parent having a critical issue.
   */
  void _criticalInconclusive() {
    _result =
        _TestNeutral.result(_title, message: 'Issue with parent - Did not run');
  }
}
