part of 'cake.dart';

/// Contextual is the base class for all Cake testing objects, such as [Test],
/// [Group], and [TestRunner].
abstract class Contextual<ContextualContext extends Context> {
  final String _title;
  String get contextualType;
  final FutureOr<void> Function(ContextualContext test)? setup;
  final FutureOr<void> Function(ContextualContext test)? teardown;
  final bool skip;

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
      _result = _TestNeutral(_title, message: 'Skipped');
    } else {
      _result = await _getResult(testContext, filterSettings);
    }

    return _result!;
  }

  FutureOr<void> _assignParent(
    dynamic parentContextBuilder,
    TestOptions? parentOptions,
    int parentCount,
  ) {
    _parentCount = parentCount + 1;
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
        return _TestFailure(_title, 'Failed during setup', err: err);
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
          return _TestFailure(
            _title,
            'Tests passed, but failed during teardown.',
            err: err,
          );
        } else {
          _messages.add(
            _TestFailure(_title, 'Failed during teardown', err: err),
          );
        }
      }
    }
    return null;
  }

  /// Creates a copy of a given context
  Future<ContextualContext> _deepCopyContext(Context oldContext) async {
    final ContextualContext? context = await _buildContext();
    if (context == null) {
      // No context was built, either from error or a builder was not provided
      return Context.deepCopy(oldContext) as ContextualContext;
    }
    context.copy(oldContext);
    return context;
  }

  FutureOr<ContextualContext?> _buildContext() async {
    if (_contextBuilder != null) {
      try {
        final ContextualContext context = await _contextBuilder!();
        context.setContextualInformation(
          title: _title,
          contextualType: contextualType,
        );
        return context;
      } catch (err) {
        _criticalFailure(
          'Failed during context building stage. If you are using a custom context, check that typing between parents and children is valid.',
          err,
        );
      }
    }
    return null;
  }

  /*
   * Used for reporting critical test-stopping issues
   */
  void _criticalFailure(String errorMessage, Object? err) {
    _result = _TestFailure(_title, errorMessage, err: err);
  }

  /*
   * Used for reporting when this test cannot run due to a parent having a critical issue.
   */
  void _criticalInconclusive() {
    _result = _TestNeutral(
      _title,
      message: 'Issue with parent - Skipped.',
    );
  }
}
