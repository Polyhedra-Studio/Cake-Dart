part of 'cake.dart';

/// Create a TestRunner with a Custom [Context]
///
/// The root node for any tests. Automatically runs once created. Do not include
/// TestRunners inside other Groups.
class TestRunner<TestRunnerContext extends Context>
    extends _TestRunner<TestRunnerContext> {
  TestRunner(
    super._title,
    super.children, {
    required super.contextBuilder,
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  });

  /// Skipped. This will not run any of the stages or children within this
  /// test runner.
  TestRunner.skip(
    super._title,
    super.children, {
    required super.contextBuilder,
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  }) : super(skip: true);
}

/// Create a TestRunner with a Default [Context] of an [ExpectedType]
///
/// The root node for any tests. Automatically runs once created. Do not include
/// TestRunners inside other Groups.
class TestRunnerOf<ExpectedType> extends _TestRunner<Context<ExpectedType>> {
  TestRunnerOf(
    super._title,
    super.children, {
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  }) : super(contextBuilder: Context<ExpectedType>.new);

  /// Skipped. This will not run any of the stages or children within this
  /// test runner.
  TestRunnerOf.skip(
    super._title,
    super.children, {
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  }) : super(skip: true, contextBuilder: Context<ExpectedType>.new);
}

/// Create a TestRunner with a Default [Context] with no or dynamic [ExpectedType]
///
/// The root node for any tests. Automatically runs once created. Do not include
/// TestRunners inside other Groups.
class TestRunnerDefault extends _TestRunner<Context> {
  TestRunnerDefault(
    super._title,
    super.children, {
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  }) : super(contextBuilder: Context.new);

  /// Skipped. This will not run any of the stages or children within this
  /// test runner.
  TestRunnerDefault.skip(
    super._title,
    super.children, {
    super.options,
    super.setup,
    super.teardown,
    super.onComplete,
  }) : super(skip: true, contextBuilder: Context.new);
}

class _TestRunner<TestRunnerContext extends Context>
    extends _Group<TestRunnerContext> {
  final FilterSettings filterSettings = FilterSettings.fromEnvironment();
  final OnComplete? onComplete;

  @override
  String get contextualType => 'TestRunner';

  _TestRunner(
    super._title,
    super.children, {
    required FutureOr<TestRunnerContext> Function() contextBuilder,
    super.options,
    super.skip,
    super.setup,
    super.teardown,
    this.onComplete,
  }) : super(contextBuilder: contextBuilder) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Since this is the root that kicks off the rest of the tests, we can begin
    // the testing lifecycle here

    // Step 0: Preflight checks
    if (skip) return complete();
    if (!_shouldRunWithFilter(filterSettings)) return complete();

    // Step 1: Setup
    //  `- 1a: Pass inheritable information down from parent to children
    //  `- 1b: Build the initial context
    _assignChildren();
    TestRunnerContext context;
    try {
      context = await _contextBuilder!();
      context.setContextualInformation(
        title: _title,
        contextualType: contextualType,
      );
    } catch (err) {
      _criticalFailure('Failed during initial context building stage.', err);
      report(filterSettings);
      return;
    }

    // Step 2: Run
    //  `- 2a: Run setup
    //  `- 2b: Create a copy of the parent context for each child
    //  `- 2c: Run action (Tests only)
    //  `- 2d: Check assertions (Tests only)
    //  `- 2e: Run teardown
    await _run(context, filterSettings);

    // Step 3: Report results
    report(filterSettings);

    // Step 4: Fire OnComplete Hook (Run under .report() or earlier)
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

      if (filterSettings.hasGroupSearchFor ||
          filterSettings.hasGroupFilterTerm) {
        // Only check against children that are groups, not tests
        return children
            .whereType<_Group>()
            .any((child) => child._shouldRunWithFilter(filterSettings));
      } else {
        _filterAppliesToChildren = true;
        return children
            .any((child) => child._shouldRunWithFilter(filterSettings));
      }
    }

    // No filter - this should run
    return true;
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

    complete(message);
  }

  void complete([String? message]) {
    if (onComplete != null) {
      onComplete!(message ?? '');
    }
  }
}

/// Callback for when all tests have finished within a test runner
///
/// Returns output summary of tests, identical to what is returned by
/// [Printer.summary()]
typedef OnComplete = void Function(String message);
