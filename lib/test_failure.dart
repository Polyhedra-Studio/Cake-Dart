part of cake;

class _TestFailure extends _TestResult {
  String message;
  Object? err;
  int? errorIndex;
  _TestFailure.result(String testTitle, this.message, {this.err})
      : super(testTitle);
  _TestFailure(this.message) : super('');

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);
    Printer.fail(spacer + _formatMessage());
    if (err != null) {
      // Extra space is to compensate for the [X]
      Printer.fail('$spacer    $err');

      if (err is Error) {
        String stack = (err as Error).stackTrace.toString();
        // Do not format this. This does not need formatting as
        // some terminals recognize this as a stack trace.
        print(stack);
      }
    }
  }

  String _formatMessage() {
    if (testTitle.isNotEmpty) {
      return '[X] $testTitle: $message';
    } else if (errorIndex != null) {
      return '    [#$errorIndex] $message';
    } else {
      return '    $message';
    }
  }
}
