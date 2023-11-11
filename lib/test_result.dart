part of 'cake.dart';

abstract class _TestResult {
  String testTitle;
  String spacer = '';

  _TestResult(this.testTitle);
  void report({int spacerCount = 0}) {
    for (int i = 0; i < spacerCount; i++) {
      if (i < spacerCount - 1) {
        spacer += '   ';
      } else {
        spacer += ' `-';
      }
    }
  }
}
