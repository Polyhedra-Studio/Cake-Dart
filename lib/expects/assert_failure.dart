part of '../cake.dart';

/// Returned after an [Expect] has failed
class AssertFailure extends AssertResult {
  final String errorMessage;
  final Object? err;

  @override
  void Function(String message) printer = Printer.fail;

  AssertFailure(this.errorMessage, {super.index, this.err})
      : super(message: errorMessage);

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
