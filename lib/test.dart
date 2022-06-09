import 'dart:async';

import 'package:cake/contextual.dart';
import 'package:cake/test_context.dart';
import 'package:cake/test_neutral.dart';

import 'expect.dart';
import 'test_failure.dart';
import 'test_pass.dart';
import 'test_result.dart';

class Test<T> extends Contextual<T> {
  final FutureOr<void> Function(TestContext<T> context)? action;
  List<Expect<dynamic>> Function(TestContext<T> context)? assertions;
  final List<TestFailure> assertFailures = [];

  Test(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(TestContext<T> context)? setup,
    FutureOr<void> Function(TestContext<T> context)? teardown,
    this.action,
    this.assertions,
  }) : super(title,
            setup: setup,
            teardown: teardown,
            context: TestContext(expected: expected, actual: actual));

  Test.single(
    String title, {
    T? expected,
    T? actual,
    FutureOr<void> Function(TestContext<T> context)? setup,
    FutureOr<void> Function(TestContext<T> context)? teardown,
    this.action,
    this.assertions,
  }) : super(
          title,
          setup: setup,
          teardown: teardown,
          context: TestContext(expected: expected, actual: actual),
          standalone: true,
        );

  @override
  Future<TestResult> getResult(TestContext testContext) async {
    // Assign parent context on top of current
    context.applyParentContext(testContext);

    TestResult? setupFailure = await runSetup(context);
    if (setupFailure != null) {
      return setupFailure;
    }

    if (action != null) {
      try {
        await action!(context);
      } catch (err) {
        // We want to try to teardown anything we've set up even if it's all haywire at this point
        result = TestFailure.result(title, 'Failed during action', err: err);
      }
    }

    // Don't bother running assertions if we've already come up if this is pass or fail
    if (result == null) {
      assertions ??= defaultAssertion;
      List<Expect> asserts = assertions!(context);

      for (var expect in asserts) {
        TestResult assertResult = expect.run();
        if (assertResult is TestFailure) {
          assertFailures.add(assertResult);
        }
      }

      if (assertFailures.isEmpty) {
        result = TestPass.result(title);
      } else {
        result = TestFailure.result(title, 'Assert failed');
      }
    }

    TestResult? teardownFailure = await runTeardown(context);
    if (teardownFailure != null) {
      return teardownFailure;
    }
    result ??= TestNeutral.result(title,
        message:
            'Expected result by now! Is this there something running asynchronously?');
    return result!;
  }

  @override
  void report() {
    result!.report(spacerCount: parentCount);
    for (TestFailure element in assertFailures) {
      element.report(spacerCount: parentCount);
    }
  }

  List<Expect<T>> defaultAssertion(TestContext<T> context) {
    return [
      Expect<T>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }
}
