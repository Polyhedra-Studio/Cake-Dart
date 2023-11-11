part of cake;

class TestRunner<TestRunnerContext extends Context>
    extends _TestRunner<TestRunnerContext> {
  TestRunner(
    super._title,
    super.children, {
    required super.contextBuilder,
    super.options,
  });

  TestRunner.skip(
    super._title,
    super.children, {
    required super.contextBuilder,
    super.options,
  }) : super(skip: true);
}

class TestRunnerOf<ExpectedType> extends _TestRunner<Context<ExpectedType>> {
  TestRunnerOf(
    super._title,
    super.children, {
    super.options,
  }) : super(contextBuilder: Context<ExpectedType>.new);

  TestRunnerOf.skip(
    super._title,
    super.children, {
    super.options,
  }) : super(skip: true, contextBuilder: Context<ExpectedType>.new);
}

class TestRunnerDefault extends _TestRunner<Context> {
  TestRunnerDefault(
    super._title,
    super.children, {
    super.options,
  }) : super(contextBuilder: Context.new);

  TestRunnerDefault.skip(
    super._title,
    super.children, {
    super.options,
  }) : super(skip: true, contextBuilder: Context.new);
}

class _TestRunner<TestRunnerContext extends Context>
    extends _Group<TestRunnerContext> {
  final FilterSettings filterSettings = FilterSettings.fromEnvironment();

  _TestRunner(
    super._title,
    super.children, {
    required TestRunnerContext Function() contextBuilder,
    super.options,
    super.skip,
  }) : super(contextBuilder: contextBuilder) {
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
    if (skip) return;
    if (!_shouldRunWithFilter(filterSettings)) return;
    await _run(_context, filterSettings);
    report(filterSettings);
  }

  @override
  void report(FilterSettings filterSettings) {
    super.report(filterSettings);

    // Get count of successes, failures, and neutrals
    final String message = Printer.summary(
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
