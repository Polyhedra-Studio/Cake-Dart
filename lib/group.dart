part of cake;

class Group extends _Group {
  Group(
    String title,
    List<Contextual> children, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
    TestOptions? options,
  }) : super(
          title,
          children,
          setup: setup,
          teardown: teardown,
          options: options,
        );
}

class GroupWithContext<GroupContext extends Context>
    extends _Group<GroupContext> {
  GroupWithContext(
    String title,
    List<Contextual<dynamic, GroupContext>> children, {
    FutureOr<void> Function(GroupContext context)? setup,
    FutureOr<void> Function(GroupContext context)? teardown,
    GroupContext Function()? contextBuilder,
    TestOptions? options,
  }) : super.context(
          title,
          children,
          setup: setup,
          teardown: teardown,
          contextBuilder: contextBuilder,
          options: options,
        );
}

class _Group<GroupContext extends Context>
    extends Contextual<dynamic, GroupContext> {
  final List<Contextual<dynamic, GroupContext>> children;
  int testSuccessCount = 0;
  int testFailCount = 0;
  int testNeutralCount = 0;
  bool _filterAppliesToChildren = false;

  _Group(
    String title,
    this.children, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
    TestOptions? options,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          simpleContext: Context(),
          options: options,
        ) {
    _assignChildren();
  }

  _Group.context(
    String title,
    this.children, {
    FutureOr<void> Function(GroupContext context)? setup,
    FutureOr<void> Function(GroupContext context)? teardown,
    required GroupContext Function()? contextBuilder,
    TestOptions? options,
  }) : super.context(
          title,
          setupWithContext: setup,
          teardownWithContext: teardown,
          contextBuilder: contextBuilder,
          context: contextBuilder != null ? contextBuilder() : null,
          options: options,
        ) {
    _assignChildren();
  }

  void _assignChildren() {
    for (Contextual child in children) {
      child._assignParent(_contextBuilder, _options);
    }
  }

  @override
  void _assignParent(
    dynamic parentContextBuilder,
    TestOptions? parentOptions,
  ) {
    super._assignParent(parentContextBuilder, parentOptions);
    if (_contextBuilder != null) {
      try {
        _context = _contextBuilder!();
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
      Context testContext, FilterSettings filterSettings) async {
    return _getResultShared(
      setupFn: () => _runSetup(testContext),
      teardownFn: () => _runTeardown(testContext),
      filterSettings: filterSettings,
      translateContextFn: (child) => child._translateContext(testContext),
      translateContextSimpleFn: (child) =>
          child._translateContextSimple(testContext),
    );
  }

  @override
  Future<_TestResult> _getResultWithContext(
      GroupContext testContext, FilterSettings filterSettings) async {
    return _getResultShared(
      setupFn: () => _runSetupWithContext(testContext),
      teardownFn: () => _runTeardownWithContext(testContext),
      translateContextFn: (child) => child._translateContext(testContext),
      translateContextSimpleFn: (child) =>
          child._translateContextSimple(testContext),
      filterSettings: filterSettings,
    );
  }

  Future<_TestResult> _getResultShared({
    required Future<_TestResult?> Function() setupFn,
    required Future<_TestResult?> Function() teardownFn,
    required Function(Contextual child) translateContextFn,
    required Function(Contextual child) translateContextSimpleFn,
    required FilterSettings filterSettings,
  }) async {
    // This is just a stub if there's no children - do nothing.
    if (children.isEmpty) {
      return _TestNeutral.result(_title, message: 'Empty - no tests');
    }

    // _TestResult? setupFailure = await _runSetupWithContext(testContext);
    _TestResult? setupFailure = await setupFn();
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children) {
      // Don't run at all if the filter does not apply to child
      if (_filterAppliesToChildren &&
          !child._shouldRunWithFilter(filterSettings)) {
        continue;
      }

      // Create a new context so siblings don't affect each other
      _TestResult result;
      dynamic childContext;
      if (child._hasCustomContext) {
        try {
          childContext = translateContextFn(child);
        } catch (err) {
          result = _TestFailure.result(
              child._title, 'Critical Error while copying context',
              err: err);
        }
      } else {
        childContext = translateContextSimpleFn(child);
      }

      // Get result from context
      if (child._hasCustomContext) {
        result = await child._runWithContext(childContext, filterSettings);
      } else {
        result = await child._run(childContext, filterSettings);
      }

      if (result is _TestPass) childSuccessCount++;
      if (result is _TestFailure) childFailCount++;
      if (child is _Test) {
        if (result is _TestPass) testSuccessCount++;
        if (result is _TestFailure) testFailCount++;
        if (result is _TestNeutral) testNeutralCount++;
      }
    }

    _TestResult? teardownFailure = await teardownFn();
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
    if (children.isNotEmpty) {
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
  void _criticalFailure(String errorMessage) {
    _result = _TestFailure.result(_title, errorMessage);
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
