part of 'cake.dart';

abstract class Contextual<ContextualContext extends Context> {
  final String _title;
  final FutureOr<void> Function(ContextualContext test)? setup;
  final FutureOr<void> Function(ContextualContext test)? teardown;
  final bool skip;

  // For some reason dart's not picking up that this is getting changed in a extended class
  // ignore: prefer_final_fields
  late ContextualContext _context;

  FutureOr<ContextualContext> Function()? _contextBuilder;
  int _parentCount = 0;
  _TestResult? _result;
  final List<_TestResult> _messages = [];
  TestOptions? _options;

  Contextual(
    this._title, {
    required this.setup,
    required this.teardown,
    FutureOr<ContextualContext> Function()? contextBuilder,
    TestOptions? options,
    this.skip = false,
  })  : _contextBuilder = contextBuilder,
        _options = options;

  void report(FilterSettings filterSettings);
  bool _shouldRunWithFilter(FilterSettings filterSettings) => false;
  Future<_TestResult> _getResult(
    ContextualContext testContext,
    FilterSettings filterSettings,
  );

  Future<_TestResult> _run(
    ContextualContext testContext,
    FilterSettings filterSettings,
  ) async {
    if (skip) {
      _result = _TestNeutral.result(_title, message: 'Skipped');
    } else {
      _result = await _getResult(testContext, filterSettings);
    }

    return _result!;
  }

  FutureOr<void> _assignParent(
    dynamic parentContextBuilder,
    TestOptions? parentOptions,
  ) {
    _parentCount++;
    // Assign and inherit the parent contextBuilder
    if (parentContextBuilder != null && _contextBuilder == null) {
      _contextBuilder = parentContextBuilder;
    }

    // Assign and inherit the parent options, if any
    if (parentOptions != null) {
      _options = _options?.mapParent(parentOptions) ?? parentOptions;
    }
  }

  Future<_TestFailure?> _runSetup(ContextualContext context) async {
    if (skip) return null;
    if (setup != null) {
      try {
        await setup!(context);
      } catch (err) {
        return _TestFailure.result(_title, 'Failed during setup', err: err);
      }
    }
    return null;
  }

  Future<_TestFailure?> _runTeardown(ContextualContext testContext) async {
    if (skip) return null;
    if (teardown != null) {
      try {
        await teardown!(testContext);
      } catch (err) {
        if (_result is _TestPass) {
          return _TestFailure.result(
            _title,
            'Tests passed, but failed during teardown.',
            err: err,
          );
        } else {
          _messages.add(
            _TestFailure.result(_title, 'Failed during teardown', err: err),
          );
        }
      }
    }
    return null;
  }

  FutureOr<ContextualContext> _translateContext(Context oldContext) async {
    if (_contextBuilder == null) {
      return Context.deepCopy(oldContext) as ContextualContext;
    }
    final ContextualContext context = await _contextBuilder!();
    context.copy(oldContext);
    return context;
  }

  /*
   * Used for reporting critical test-stopping issues
   */
  void _criticalFailure(String errorMessage, Object? err) {
    _result = _TestFailure.result(_title, errorMessage, err: err);
  }

  /*
   * Used for reporting when this test cannot run due to a parent having a critical issue.
   */
  void _criticalInconclusive() {
    _result = _TestNeutral.result(
      _title,
      message: 'Issue with parent - Skipped.',
    );
  }
}
