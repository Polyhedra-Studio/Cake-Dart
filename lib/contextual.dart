import 'dart:async';

import 'package:cake/test_context.dart';
import 'package:cake/test_failure.dart';
import 'package:cake/test_pass.dart';
import 'package:cake/test_result.dart';

abstract class Contextual<T> {
  String title;
  final FutureOr<void> Function(TestContext<T> context)? setup;
  final FutureOr<void> Function(TestContext<T> context)? teardown;
  final TestContext<T> context;
  int parentCount = 0;
  TestResult? result;
  List<TestResult> messages = [];
  bool? standalone;

  Contextual(this.title,
      {this.setup, this.teardown, TestContext<T>? context, this.standalone})
      : context = context ?? TestContext<T>.empty() {
    if (standalone == true) {
      _runAndReport();
    }
  }

  void report();
  Future<TestResult> getResult(TestContext testContext);

  Future<TestResult> run(TestContext testContext) async {
    result = await getResult(testContext);
    return result!;
  }

  void _runAndReport() {
    run(context).then((value) => report());
  }

  void assignParent() {
    parentCount++;
  }

  Future<TestResult?> runSetup(TestContext<T> testContext) async {
    if (setup != null) {
      try {
        await setup!(testContext);
      } catch (err) {
        return TestFailure.result(title, 'Failed during setup', err: err);
      }
    }

    return null;
  }

  Future<TestResult?> runTeardown(TestContext<T> testContext) async {
    if (teardown != null) {
      try {
        await teardown!(testContext);
      } catch (err) {
        if (result is TestPass) {
          return TestFailure.result(
              title, 'Tests passed, but failed during teardown.',
              err: err);
        } else {
          messages.add(
              TestFailure.result(title, 'Failed during teardown', err: err));
        }
      }
    }
    return null;
  }
}
