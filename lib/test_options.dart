part of 'cake.dart';

class TestOptions {
  final bool? _failOnFirstExpect;
  bool get failOnFirstAssert => _failOnFirstExpect ?? true;

  const TestOptions({bool? failOnFirstExpect})
      : _failOnFirstExpect = failOnFirstExpect;

  TestOptions mapParent(TestOptions parent) {
    return TestOptions(
      failOnFirstExpect: _failOnFirstExpect ?? parent._failOnFirstExpect,
    );
  }
}
