import 'expect.dart';
import 'test_failure.dart';
import 'test_pass.dart';
import 'test_result.dart';

class Test<T> {
  String title;
  void Function(TestContext<T> context)? setup;
  void Function(TestContext<T> context)? action;
  List<Expect<dynamic>> Function(TestContext<T> context)? assertions;
  TestResult? result;
  List<TestFailure> assertFailures = [];
  TestContext<T> context;

  Test(
    this.title, {
    T? expected,
    T? actual,
    this.setup,
    this.action,
    this.assertions,
  }) : context = TestContext<T>(expected, actual) {
    run();
  }

  void run() {
    if (setup != null) {
      try {
        setup!(context);
      } catch (err) {
        result = TestFailure.result(title, 'Failed during setup', err: err);
      }
    }

    if (action != null) {
      try {
        action!(context);
      } catch (err) {
        result = TestFailure.result(title, 'Failed during action', err: err);
      }
    }

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

    if (result == null) {
      throw '$title: Expected result by now! Is this actually an asynchronous function?';
    }

    result!.report();
    for (TestFailure element in assertFailures) {
      element.report();
    }
  }

  List<Expect<T>> defaultAssertion(TestContext<T> context) {
    return [
      Expect<T>(ExpectType.equals,
          expected: context.expected, actual: context.actual)
    ];
  }
}

class TestContext<T> {
  Map<String, dynamic> context = {};
  T? expected;
  T? actual;

  TestContext(this.expected, this.actual);
}
