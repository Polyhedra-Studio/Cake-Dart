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
  final FilterSettings filterSettings = FilterSettings.fromEnvironment();

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

  @override
  bool _shouldRunWithFilter(FilterSettings filterSettings) {
    if (filterSettings.hasTestRunnerSearchFor) {
      return filterSettings.testRunnerSearchFor == _title;
    }
    if (filterSettings.hasTestRunnerFilterTerm) {
      return _title.contains(filterSettings.testFilterTerm!);
    }
    if (filterSettings.isNotEmpty) {
      // Check if the general search term applies here
      if (filterSettings.hasGeneralSearchTerm &&
          _title.contains(filterSettings.generalSearchTerm!)) {
        return true;
      }

      // Check if children should run, if so this should run
      _filterAppliesToChildren = true;
      return children
          .any((child) => child._shouldRunWithFilter(filterSettings));
    }

    // No filter - this should run
    return true;
  }

  Future<void> _runAll() async {
    if (!_shouldRunWithFilter(filterSettings)) return;
    await _run(simpleContext!, filterSettings);
    report();
  }

  Future<void> _runAllWithContext() async {
    if (!_shouldRunWithFilter(filterSettings)) return;
    await _runWithContext(_context!, filterSettings);
    report();
  }

  @override
  void report() {
    super.report();

    // Get count of successes, failures, and neutrals
    String message = Printer.summary(
      total: total,
      successes: successes,
      failures: failures,
      neutrals: neutrals,
    );
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
