import 'package:cake/helper/printer.dart';

import 'test_result.dart';

class TestFailure extends TestResult {
  String message;
  Object? err;
  TestFailure.result(String testTitle, this.message, {this.err})
      : super(testTitle);
  TestFailure(this.message, {this.err}) : super('');

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);
    Printer.fail(spacer + _formatMessage());
    if (err != null && err is String) {
      Printer.fail(spacer + (err as String));
    }
  }

  String _formatMessage() {
    if (testTitle.isNotEmpty) {
      return '[X] $testTitle: $message';
    } else {
      return '    $message';
    }
  }
}
