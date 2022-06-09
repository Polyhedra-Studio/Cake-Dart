import 'package:cake/helper/printer.dart';

import 'test_result.dart';

class TestPass extends TestResult {
  TestPass.result(String test) : super(test);
  TestPass() : super('');

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);

    if (testTitle.isNotEmpty) {
      Printer.pass('$spacer(O) $testTitle');
    }
  }
}
