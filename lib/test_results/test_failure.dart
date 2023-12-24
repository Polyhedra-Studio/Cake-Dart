part of '../cake.dart';

class _TestFailure extends _TestResult {
  String message;
  Object? err;

  @override
  String formatMessage() {
    return '[X] $testTitle: $message';
  }

  @override
  void Function(String message) printer = Printer.fail;
  _TestFailure(super.testTitle, this.message, {this.err});

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);
    if (err != null) {
      // Extra space is to compensate for the [X]
      Printer.fail('$spacer    $err');

      if (err is Error) {
        final String stack = (err as Error).stackTrace.toString();
        // Do not format this. This does not need formatting as
        // some terminals recognize this as a stack trace.
        print(stack);
      }
    }
  }
}
