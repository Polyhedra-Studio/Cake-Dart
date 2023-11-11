part of 'cake.dart';

class _TestPass extends _TestResult {
  _TestPass.result(super.testTitle);
  _TestPass() : super('');

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);

    if (testTitle.isNotEmpty) {
      Printer.pass('$spacer(O) $testTitle');
    }
  }
}
