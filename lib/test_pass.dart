import 'package:cake/helper/printer.dart';

import 'test_result.dart';

class TestPass extends TestResult {
  TestPass.result(String test) : super(test);
  TestPass() : super('');

  @override
  void report() {
    if (testTitle.isNotEmpty) {
      Printer.pass('(O) $testTitle');
    }
  }
}
