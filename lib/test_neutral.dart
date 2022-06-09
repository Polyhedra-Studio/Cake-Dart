import 'package:cake/helper/printer.dart';
import 'package:cake/test_result.dart';

class TestNeutral extends TestResult {
  String? message;

  TestNeutral() : super('');
  TestNeutral.result(String testTitle, {this.message}) : super(testTitle);

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);

    if (message != null) {
      Printer.neutral('$spacer    ${message!}');
    } else {
      Printer.neutral('$spacer(-) $testTitle');
    }
  }
}
