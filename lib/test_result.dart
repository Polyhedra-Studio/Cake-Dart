abstract class TestResult {
  String testTitle;
  String spacer = '';

  TestResult(this.testTitle);
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
