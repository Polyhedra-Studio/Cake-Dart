part of '../cake.dart';

class _TestNeutral extends _TestResult {
  String? message;

  @override
  String formatMessage() => '(-) $testTitle: $message';

  @override
  void Function(String message) printer = Printer.neutral;

  _TestNeutral(
    super.testTitle, {
    this.message,
  });
}
