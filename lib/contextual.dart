part of cake;

abstract class Contextual<T, C extends Context<T>> {
  String title;
  final FutureOr<void> Function(Context<T> test)? setup;
  final FutureOr<void> Function(C test)? setupWithContext;
  final FutureOr<void> Function(Context<T> test)? teardown;
  final FutureOr<void> Function(C test)? teardownWithContext;

  final Context<T>? simpleContext;
  final C? context;
  final C Function()? contextBuilder;

  int parentCount = 0;
  _TestResult? _result;
  final List<_TestResult> _messages = [];
  bool hasCustomContext;

  Contextual(
    this.title, {
    this.setup,
    this.teardown,
    this.simpleContext,
  })  : hasCustomContext = false,
        context = null,
        setupWithContext = null,
        teardownWithContext = null,
        contextBuilder = null;

  Contextual.context(
    this.title, {
    required this.setupWithContext,
    required this.teardownWithContext,
    required this.contextBuilder,
    required this.context,
  })  : hasCustomContext = true,
        setup = null,
        teardown = null,
        simpleContext = null;

  void report();
  Future<_TestResult> _getResult(Context<T> testContext);
  Future<_TestResult> _getResultWithContext(C testContext);

  Future<_TestResult> _run(Context<T> testContext) async {
    _result = await _getResult(testContext);
    return _result!;
  }

  Future<_TestResult> _runWithContext(C testContext) async {
    _result = await _getResultWithContext(testContext);
    return _result!;
  }

  void _assignParent() {
    parentCount++;
  }

  Future<_TestResult?> _runSetup(Context<T> simpleContext) async {
    if (setup != null) {
      try {
        await setup!(simpleContext);
      } catch (err) {
        return _TestFailure.result(title, 'Failed during setup', err: err);
      }
    }

    return null;
  }

  Future<_TestResult?> _runSetupWithContext(C context) async {
    if (setupWithContext != null) {
      try {
        await setupWithContext!(context);
      } catch (err) {
        return _TestFailure.result(title, 'Failed during setup', err: err);
      }
    }
    return null;
  }

  Future<_TestResult?> _runTeardown(Context<T> testContext) async {
    if (teardown != null) {
      try {
        await teardown!(testContext);
      } catch (err) {
        if (_result is _TestPass) {
          return _TestFailure.result(
              title, 'Tests passed, but failed during teardown.',
              err: err);
        } else {
          _messages.add(
              _TestFailure.result(title, 'Failed during teardown', err: err));
        }
      }
    }
    return null;
  }

  Future<_TestResult?> _runTeardownWithContext(C testContext) async {
    if (teardown != null) {
      try {
        await teardownWithContext!(testContext);
      } catch (err) {
        if (_result is _TestPass) {
          return _TestFailure.result(
              title, 'Tests passed, but failed during teardown.',
              err: err);
        } else {
          _messages.add(
              _TestFailure.result(title, 'Failed during teardown', err: err));
        }
      }
    }
    return null;
  }

  Context<T> _translateContextSimple(Context oldContext) {
    return Context<T>.deepCopy(oldContext);
  }

  C _translateContext(Context oldContext) {
    return contextBuilder!()..copy(oldContext);
  }
}
