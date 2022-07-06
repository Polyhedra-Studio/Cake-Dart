import 'dart:async';

import 'package:cake/context.dart';

import 'package:cake/test_failure.dart';
import 'package:cake/test_pass.dart';
import 'package:cake/test_result.dart';

abstract class Contextual<T> {
  String title;
  final FutureOr<void> Function(Context<T> context)? setup;
  final FutureOr<void> Function(Context<T> context)? teardown;
  final Context<T> context;
  int parentCount = 0;
  TestResult? result;
  List<TestResult> messages = [];
  bool? standalone;

  Contextual(this.title,
      {this.setup, this.teardown, Context<T>? context, this.standalone})
      : context = context ?? Context<T>() {
    if (standalone == true) {
      _runAndReport();
    }
  }

  void report();
  Future<TestResult> getResult(Context<T> testContext);

  Future<TestResult> run(Context<T> testContext) async {
    result = await getResult(testContext);
    return result!;
  }

  void _runAndReport() {
    run(context).then((value) => report());
  }

  void assignParent() {
    parentCount++;
  }

  Future<TestResult?> runSetup(Context<T> testContext) async {
    if (setup != null) {
      try {
        await setup!(testContext);
      } catch (err) {
        return TestFailure.result(title, 'Failed during setup', err: err);
      }
    }

    return null;
  }

  Future<TestResult?> runTeardown(Context<T> testContext) async {
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

  Context<T> translateContext(Context oldContext) {
    return Context<T>.deepCopy(oldContext);
  }
}
