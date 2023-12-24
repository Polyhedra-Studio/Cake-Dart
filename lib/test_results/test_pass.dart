part of '../cake.dart';

class _TestPass extends _TestResult {
  @override
  void Function(String message) printer = Printer.pass;
  @override
  String formatMessage() => '(O) $testTitle';

  _TestPass(super.testTitle);
}
