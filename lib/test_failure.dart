import 'package:cake/helper/printer.dart';

import 'test_result.dart';

class TestFailure extends TestResult {
  String message;
  Object? err;
  TestFailure.result(String testTitle, this.message, {this.err})
      : super(testTitle);
  TestFailure(this.message, {this.err}) : super('');

  @override
  void report() {
    if (testTitle.isNotEmpty) {
      Printer.fail('[X] $testTitle: $message');
    } else {
      Printer.fail(message);
    }
    if (err != null && err is String) {
      Printer.fail(err as String);
    }
  }
}
