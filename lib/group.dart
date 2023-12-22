part of 'cake.dart';

class GroupOf<ExpectedType> extends _Group<Context<ExpectedType>> {
  GroupOf(
    super._title,
    super.children, {
    super.setup,
    super.teardown,
    super.options,
  }) : super(
          contextBuilder: Context<ExpectedType>.new,
        );

  GroupOf.skip(
    super._title,
    super.children, {
    super.setup,
    super.teardown,
    super.options,
  }) : super(contextBuilder: Context<ExpectedType>.new, skip: true);
}

class Group<GroupContext extends Context> extends _Group<GroupContext> {
  Group(
    super._title,
    super.children, {
    super.setup,
    super.teardown,
    super.contextBuilder,
    super.options,
  });

  Group.skip(
    super._title,
    super.children, {
    super.setup,
    super.teardown,
    super.contextBuilder,
    super.options,
  }) : super(skip: true);
}

class _Group<GroupContext extends Context> extends Contextual<GroupContext> {
  final List<Contextual<GroupContext>> children;
  int testSuccessCount = 0;
  int testFailCount = 0;
  int testNeutralCount = 0;
  bool _filterAppliesToChildren = false;

  _Group(
    super._title,
    this.children, {
    super.setup,
    super.teardown,
    required super.contextBuilder,
    super.options,
    super.skip,
  }) {
    _assignChildren();
  }

  void _assignChildren() {
    for (Contextual<GroupContext> child in children) {
      child._assignParent(_contextBuilder, _options);
    }
  }

  @override
  FutureOr<void> _assignParent(
    dynamic parentContextBuilder,
    TestOptions? parentOptions,
  ) async {
    super._assignParent(parentContextBuilder, parentOptions);
    if (_contextBuilder != null) {
      try {
        _context = await _contextBuilder!();
      } catch (err) {
        throw 'Cake Test Runner: Issue setting up test "$_title". Test context is getting a different type than expected. Check parent groups and test runners.';
      }
    }
    _assignChildren();
  }

  @override
  bool _shouldRunWithFilter(FilterSettings filterSettings) {
    // This should run fairly close to TestRunner's version
    if (filterSettings.hasGroupSearchFor) {
      return filterSettings.groupSearchFor == _title;
    }
    if (filterSettings.hasGroupFilterTerm) {
      return _title.contains(filterSettings.groupFilterTerm!);
    }
    // filterSettings.isNotEmpty also includes test runner filters,
    // which should already be checked at this point
    if (filterSettings.hasGeneralSearchTerm ||
        filterSettings.hasTestFilterTerm ||
        filterSettings.hasTestSearchFor) {
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

    // No applicable filter - this should run
    return true;
  }

  @override
  Future<_TestResult> _getResult(
    GroupContext testContext,
    FilterSettings filterSettings,
  ) async {
    return _getResultShared(
      setupFn: () => _runSetup(testContext),
      teardownFn: () => _runTeardown(testContext),
      translateContextFn: (child) => child._translateContext(testContext),
      filterSettings: filterSettings,
    );
  }

  Future<_TestResult> _getResultShared({
    required Future<_TestFailure?> Function() setupFn,
    required Future<_TestFailure?> Function() teardownFn,
    required FutureOr<GroupContext> Function(Contextual<GroupContext> child)
        translateContextFn,
    required FilterSettings filterSettings,
  }) async {
    // This is just a stub if there's no children - do nothing.
    if (children.isEmpty) {
      return _TestNeutral.result(_title, message: 'Empty - no tests.');
    }

    // This has been marked as skipped - do nothing.
    if (skip) {
      return _TestNeutral.result(_title, message: 'Skipped.');
    }

    final _TestFailure? setupFailure = await setupFn();
    if (setupFailure != null) {
      _criticalFailure(setupFailure.message, setupFailure.err);
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual<GroupContext> child in children) {
      // Don't run at all if the filter does not apply to child
      if (_filterAppliesToChildren &&
          !child._shouldRunWithFilter(filterSettings)) {
        continue;
      }

      // Create a new context so siblings don't affect each other
      final GroupContext childContext = await translateContextFn(child);
      final _TestResult result = await child._run(childContext, filterSettings);

      if (result is _TestPass) childSuccessCount++;
      if (result is _TestFailure) childFailCount++;
      if (child is _Test) {
        if (result is _TestPass) testSuccessCount++;
        if (result is _TestFailure) testFailCount++;
        if (result is _TestNeutral) testNeutralCount++;
      }
    }

    final _TestResult? teardownFailure = await teardownFn();
    if (teardownFailure != null) {
      return teardownFailure;
    }

    if (childFailCount > 0) {
      return _TestFailure.result(_title, 'Some tests failed.');
    }

    if (childSuccessCount < 1) {
      return _TestNeutral.result(_title);
    }

    return _TestPass.result(_title);
  }

  @override
  void report(FilterSettings filterSettings) {
    _result!.report(spacerCount: _parentCount);
    if (children.isNotEmpty && skip == false) {
      for (Contextual child in children) {
        if (_filterAppliesToChildren) {
          if (child._shouldRunWithFilter(filterSettings)) {
            child.report(filterSettings);
          }
        } else {
          child.report(filterSettings);
        }
      }
    }
  }

  int get successes {
    int currentSuccessCount = testSuccessCount;
    children
        .whereType<_Group>()
        .forEach((element) => currentSuccessCount += element.successes);
    return currentSuccessCount;
  }

  int get failures {
    int currentFailureCount = testFailCount;
    children
        .whereType<_Group>()
        .forEach((element) => currentFailureCount += element.failures);
    return currentFailureCount;
  }

  int get neutrals {
    int currentNeutralCount = testNeutralCount;
    children
        .whereType<_Group>()
        .forEach((element) => currentNeutralCount += element.neutrals);
    return currentNeutralCount;
  }

  int get total {
    int testCount = children
        .whereType<_Test>()
        .where((element) => element.ranSuccessfully != null)
        .length;
    children
        .whereType<_Group>()
        .forEach((element) => testCount += element.total);
    return testCount;
  }

  @override
  void _criticalFailure(String errorMessage, Object? err) {
    super._criticalFailure(errorMessage, err);
    for (var element in children) {
      element._criticalInconclusive();
      if (element is Test) {
        testNeutralCount++;
      } else {}
    }
  }

  @override
  void _criticalInconclusive() {
    super._criticalInconclusive();
    for (var element in children) {
      element._criticalInconclusive();
      testNeutralCount++;
    }
  }
}
