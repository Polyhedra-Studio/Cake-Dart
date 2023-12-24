part of 'cake.dart';

class TestMessage extends _TestResult {
  String? message;

  @override
  void Function(String message) printer = Printer.neutral;

  TestMessage(super.testTitle, {this.message});

  @override
  void report({int spacerCount = 0}) {
    setSpacer(spacerCount: spacerCount);
    Printer.neutral(spacer + formatMessage());
  }

  @override
  String formatMessage() {
    String formatMessage = testTitle;
    if (message != null) {
      formatMessage += ': $message';
    }

    return formatMessage;
  }
}
