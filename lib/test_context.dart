class TestContext<T> {
  Map<String, dynamic> context = {};
  T? expected;
  T? actual;

  TestContext({this.expected, this.actual});
  TestContext.empty();

  TestContext.deepCopy(TestContext<T> testContext)
      : context = testContext.context,
        expected = testContext.expected,
        actual = testContext.actual;

  void applyParentContext(TestContext<dynamic> parentContext) {
    context = parentContext.context;
  }
}
