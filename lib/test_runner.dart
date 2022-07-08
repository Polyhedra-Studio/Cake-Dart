part of cake;

class TestRunner extends _TestRunner {
  TestRunner(String title, List<Contextual> tests) : super(title, tests);
}

class TestRunnerWithContext<T, C extends Context<T>> extends _TestRunner<T, C> {
  TestRunnerWithContext(String title, List<Contextual<T, C>> tests,
      {required C Function() contextBuilder})
      : super.context(title, tests, contextBuilder: contextBuilder);
}

class _TestRunner<T, C extends Context<T>> extends _Group<T, C> {
  final List<Contextual<T, C>> tests;

  _TestRunner(String title, this.tests) : super(title, tests) {
    _runAll();
  }

  _TestRunner.context(
    String title,
    this.tests, {
    required C Function() contextBuilder,
  }) : super.context(title, tests, contextBuilder: contextBuilder) {
    _runAllWithContext();
  }

  Future<void> _runAll() async {
    await _run(simpleContext!);
    report();
  }

  Future<void> _runAllWithContext() async {
    await _runWithContext(_context!);
    report();
  }

  @override
  void report() {
    super.report();

    // Get count of successes, failures, and neutrals
    String message = '''

-- Summary: -------------------
|                             |
|  $total tests ran.               |
|  - $successes passed.                |
|  - $failures failed.                |
|  - $neutrals skipped/inconclusive.  |
-------------------------------
''';
    if (_result is _TestPass) {
      Printer.pass(message);
    }
    if (_result is _TestFailure) {
      Printer.fail(message);
    }
    if (_result is _TestNeutral) {
      Printer.neutral(message);
    }
  }
}
