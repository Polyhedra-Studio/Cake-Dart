part of cake;

class _TestFailure extends _TestResult {
  String message;
  Object? err;
  _TestFailure.result(String testTitle, this.message, {this.err})
      : super(testTitle);
  _TestFailure(this.message) : super('');

  @override
  void report({int spacerCount = 0}) {
    super.report(spacerCount: spacerCount);
    Printer.fail(spacer + _formatMessage());
    if (err != null && err is String) {
      Printer.fail(spacer + (err as String));
    }
  }

  String _formatMessage() {
    if (testTitle.isNotEmpty) {
      return '[X] $testTitle: $message';
    } else {
      return '    $message';
    }
  }
}
