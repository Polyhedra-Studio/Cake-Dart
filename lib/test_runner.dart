import 'package:cake/contextual.dart';
import 'package:cake/group.dart';
import 'package:cake/helper/printer.dart';
import 'package:cake/test_failure.dart';
import 'package:cake/test_neutral.dart';
import 'package:cake/test_pass.dart';

class TestRunner extends Group {
  final List<Contextual> tests;

  TestRunner(String title, this.tests) : super(title, children: tests) {
    _runAll();
  }

  Future<void> _runAll() async {
    await run(context);
    report();
  }

  @override
  void report() {
    super.report();

    // Get count of successes, failures, and neutrals
    String message = '''

-- Summary: -------------------
|                             |
|  $total tests ran.               |
|  - $successes passed.                |
|  - $failures failed.                |
|  - $neutrals skipped/inconclusive.  |
-------------------------------
''';
    if (result is TestPass) {
      Printer.pass(message);
    }
    if (result is TestFailure) {
      Printer.fail(message);
    }
    if (result is TestNeutral) {
      Printer.neutral(message);
    }
  }
}
