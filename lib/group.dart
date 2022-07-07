part of cake;

class Group extends _Group {
  Group(
    String title, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
    List<Contextual>? children,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          children: children,
        );
}

class GroupWithContext<T, C extends Context<T>> extends _Group<T, C> {
  GroupWithContext(
    String title, {
    FutureOr<void> Function(C context)? setup,
    FutureOr<void> Function(C context)? teardown,
    required C Function() contextBuilder,
    List<Contextual>? children,
  }) : super.context(
          title,
          setup: setup,
          teardown: teardown,
          children: children,
          contextBuilder: contextBuilder,
        );
}

class _Group<T, C extends Context<T>> extends Contextual<T, C> {
  final List<Contextual>? children;
  int testSuccessCount = 0;
  int testFailCount = 0;
  int testNeutralCount = 0;

  _Group(
    String title, {
    FutureOr<void> Function(Context<T> context)? setup,
    FutureOr<void> Function(Context<T> context)? teardown,
    this.children,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          simpleContext: Context(),
        ) {
    _assignChildren();
  }

  _Group.context(
    String title, {
    FutureOr<void> Function(C context)? setup,
    FutureOr<void> Function(C context)? teardown,
    required C Function() contextBuilder,
    this.children,
  }) : super.context(
          title,
          setupWithContext: setup,
          teardownWithContext: teardown,
          contextBuilder: contextBuilder,
          context: contextBuilder(),
        ) {
    _assignChildren();
  }

  void _assignChildren() {
    if (children == null) return;
    for (Contextual child in children!) {
      child._assignParent();
    }
  }

  @override
  void _assignParent() {
    super._assignParent();
    _assignChildren();
  }

  @override
  Future<_TestResult> _getResult(Context<T> testContext) async {
    // This is just a stub if there's no children - do nothing.
    if (children == null || children!.isEmpty) {
      return _TestNeutral.result(title, message: 'Empty - no tests');
    }

    _TestResult? setupFailure = await _runSetup(testContext);
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children!) {
      // Create a new context so siblings don't affect each other
      var childContext = child._translateContextSimple(testContext);
      _TestResult result = await child._run(childContext);
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
      return _TestFailure.result(title, 'Some tests failed.');
    }

    if (childSuccessCount < 1) {
      return _TestNeutral.result(title);
    }

    return _TestPass.result(title);
  }

  @override
  Future<_TestResult> _getResultWithContext(C testContext) async {
    // This is just a stub if there's no children - do nothing.
    if (children == null || children!.isEmpty) {
      return _TestNeutral.result(title, message: 'Empty - no tests');
    }

    _TestResult? setupFailure = await _runSetupWithContext(context!);
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children!) {
      // Create a new context so siblings don't affect each other
      var childContext = child._translateContext(testContext);
      _TestResult result = await child._run(childContext);
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
      return _TestFailure.result(title, 'Some tests failed.');
    }

    if (childSuccessCount < 1) {
      return _TestNeutral.result(title);
    }

    return _TestPass.result(title);
  }

  @override
  void report() {
    _result!.report(spacerCount: parentCount);
    if (children != null && children!.isNotEmpty) {
      for (Contextual child in children!) {
        child.report();
      }
    }
  }

  int get successes {
    int currentSuccessCount = testSuccessCount;
    children
        ?.whereType<Group>()
        .forEach((element) => currentSuccessCount += element.successes);
    return currentSuccessCount;
  }

  int get failures {
    int currentFailureCount = testFailCount;
    children
        ?.whereType<Group>()
        .forEach((element) => currentFailureCount += element.failures);
    return currentFailureCount;
  }

  int get neutrals {
    int currentNeutralCount = testNeutralCount;
    children
        ?.whereType<Group>()
        .forEach((element) => currentNeutralCount += element.neutrals);
    return currentNeutralCount;
  }

  int get total {
    int testCount = children?.whereType<Test>().length ?? 0;
    children
        ?.whereType<Group>()
        .forEach((element) => testCount += element.total);
    return testCount;
  }
}
