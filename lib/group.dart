import 'dart:async';

import 'package:cake/context.dart';
import 'package:cake/contextual.dart';
import 'package:cake/test.dart';
import 'package:cake/test_failure.dart';
import 'package:cake/test_neutral.dart';
import 'package:cake/test_pass.dart';
import 'package:cake/test_result.dart';

class Group extends Contextual {
  final List<Contextual>? children;
  int testSuccessCount = 0;
  int testFailCount = 0;
  int testNeutralCount = 0;

  Group(
    String title, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
    this.children,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
        ) {
    _assignChildren();
  }

  Group.single(
    String title, {
    FutureOr<void> Function(Context context)? setup,
    FutureOr<void> Function(Context context)? teardown,
    this.children,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          standalone: true,
        ) {
    _assignChildren();
  }

  void _assignChildren() {
    if (children == null) return;
    for (Contextual child in children!) {
      child.assignParent();
    }
  }

  @override
  void assignParent() {
    super.assignParent();
    _assignChildren();
  }

  @override
  Future<TestResult> getResult(Context testContext) async {
    // This is just a stub if there's no children - do nothing.
    if (children == null || children!.isEmpty) {
      return TestNeutral.result(title, message: 'Empty - no tests');
    }

    TestResult? setupFailure = await runSetup(testContext);
    if (setupFailure != null) {
      return setupFailure;
    }

    // Continue with children
    int childSuccessCount = 0;
    int childFailCount = 0;
    for (Contextual child in children!) {
      // Create a new context so siblings don't affect each other

      Context childContext = child.translateContext(testContext);
      TestResult result = await child.run(childContext);
      child.result = result;
      if (result is TestPass) childSuccessCount++;
      if (result is TestFailure) childFailCount++;
      if (child is Test) {
        if (result is TestPass) testSuccessCount++;
        if (result is TestFailure) testFailCount++;
        if (result is TestNeutral) testNeutralCount++;
      }
    }

    TestResult? teardownFailure = await runTeardown(testContext);
    if (teardownFailure != null) {
      return teardownFailure;
    }

    if (childFailCount > 0) {
      return TestFailure.result(title, 'Some tests failed.');
    }

    if (childSuccessCount < 1) {
      return TestNeutral.result(title);
    }

    return TestPass.result(title);
  }

  @override
  void report() {
    result!.report(spacerCount: parentCount);
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
