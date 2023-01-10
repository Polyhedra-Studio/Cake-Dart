part of cake;

class TestRunner<TestRunnerContext extends Context>
    extends _TestRunner<TestRunnerContext> {
  TestRunner(
    String title,
    List<Contextual<TestRunnerContext>> tests, {
    required TestRunnerContext Function() contextBuilder,
    TestOptions? options,
  }) : super(
          title,
          tests,
          contextBuilder: contextBuilder,
          options: options,
        );
}

class TestRunnerDefault extends TestRunner<Context> {
  TestRunnerDefault(
    String title,
    List<Contextual<Context>> tests, {
    TestOptions? options,
  }) : super(title, tests, contextBuilder: Context.new, options: options);
}

class _TestRunner<TestRunnerContext extends Context>
    extends _Group<TestRunnerContext> {
  final List<Contextual<TestRunnerContext>> tests;
  final FilterSettings filterSettings = FilterSettings.fromEnvironment();

  _TestRunner(
    String title,
    this.tests, {
    required TestRunnerContext Function() contextBuilder,
    TestOptions? options,
  }) : super(
          title,
          tests,
          contextBuilder: contextBuilder,
          options: options,
        ) {
    // Since this is the root that kicks off the rest of the tests, build that context
    _context = contextBuilder();
    _runAll();
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
    await _run(_context, filterSettings);
    report(filterSettings);
  }

  @override
  void report(FilterSettings filterSettings) {
    super.report(filterSettings);

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
