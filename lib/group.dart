part of cake;

class Group extends _Group {
  Group(
    String title,
    List<Contextual> children, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
  }) : super(
          title,
          children,
          setup: setup,
          teardown: teardown,
        );
}

class GroupWithContext<T, C extends Context<T>> extends _Group<T, C> {
  GroupWithContext(
    String title,
    List<Contextual<T, C>> children, {
    FutureOr<void> Function(C context)? setup,
    FutureOr<void> Function(C context)? teardown,
    C Function()? contextBuilder,
  }) : super.context(
          title,
          children,
          setup: setup,
          teardown: teardown,
          contextBuilder: contextBuilder,
        );
}

class _Group<T, C extends Context<T>> extends Contextual<T, C> {
  final List<Contextual<T, C>> children;
  int testSuccessCount = 0;
  int testFailCount = 0;
  int testNeutralCount = 0;

  _Group(
    String title,
    this.children, {
    FutureOr<void> Function(Context<T> context)? setup,
    FutureOr<void> Function(Context<T> context)? teardown,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          simpleContext: Context(),
        ) {
    _assignChildren();
  }

  _Group.context(
    String title,
    this.children, {
    FutureOr<void> Function(C context)? setup,
    FutureOr<void> Function(C context)? teardown,
    required C Function()? contextBuilder,
  }) : super.context(
          title,
          setupWithContext: setup,
          teardownWithContext: teardown,
          contextBuilder: contextBuilder,
          context: contextBuilder != null ? contextBuilder() : null,
        ) {
    _assignChildren();
  }

  void _assignChildren() {
    for (Contextual child in children) {
      child._assignParent(_contextBuilder);
    }
  }

  @override
  void _assignParent(dynamic parentContextBuilder) {
    super._assignParent(parentContextBuilder);
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
  Future<_TestResult> _getResult(Context<T> testContext) async {
    // This is just a stub if there's no children - do nothing.
    if (children.isEmpty) {
      return _TestNeutral.result(_title, message: 'Empty - no tests');
    }

    _TestResult? setupFailure = await _runSetup(testContext);
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children) {
      // Create a new context so siblings don't affect each other
      _TestResult result;
      if (child._hasCustomContext) {
        var childContext = child._translateContext(testContext);
        result = await child._runWithContext(childContext);
      } else {
        var childContext = child._translateContextSimple(testContext);
        result = await child._run(childContext);
      }
      child._result = result;
      if (result is _TestPass) childSuccessCount++;
      if (result is _TestFailure) childFailCount++;
      if (child is Test) {
        if (result is _TestPass) testSuccessCount++;
        if (result is _TestFailure) testFailCount++;
        if (result is _TestNeutral) testNeutralCount++;
      }
    }

    _TestResult? teardownFailure = await _runTeardown(testContext);
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
  Future<_TestResult> _getResultWithContext(C testContext) async {
    // This is just a stub if there's no children - do nothing.
    if (children.isEmpty) {
      return _TestNeutral.result(_title, message: 'Empty - no tests');
    }

    _TestResult? setupFailure = await _runSetupWithContext(_context!);
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children) {
      // Create a new context so siblings don't affect each other
      var childContext = child._translateContext(testContext);
      _TestResult result = await child._runWithContext(childContext);
      child._result = result;
      if (result is _TestPass) childSuccessCount++;
      if (result is _TestFailure) childFailCount++;
      if (child is Test) {
        if (result is _TestPass) testSuccessCount++;
        if (result is _TestFailure) testFailCount++;
        if (result is _TestNeutral) testNeutralCount++;
      }
    }

    _TestResult? teardownFailure = await _runTeardownWithContext(testContext);
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
  void report() {
    _result!.report(spacerCount: _parentCount);
    if (children.isNotEmpty) {
      for (Contextual child in children) {
        child.report();
      }
    }
  }

  int get successes {
    int currentSuccessCount = testSuccessCount;
    children
        .whereType<Group>()
        .forEach((element) => currentSuccessCount += element.successes);
    return currentSuccessCount;
  }

  int get failures {
    int currentFailureCount = testFailCount;
    children
        .whereType<Group>()
        .forEach((element) => currentFailureCount += element.failures);
    return currentFailureCount;
  }

  int get neutrals {
    int currentNeutralCount = testNeutralCount;
    children
        .whereType<Group>()
        .forEach((element) => currentNeutralCount += element.neutrals);
    return currentNeutralCount;
  }

  int get total {
    int testCount = children.whereType<Test>().length;
    children
        .whereType<Group>()
        .forEach((element) => testCount += element.total);
    return testCount;
  }
}
