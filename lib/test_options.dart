part of 'cake.dart';

/// Options are an inheritable object that can be set on a [TestRunner], [Group],
/// or [Test]. Any child settings will override parent settings, if set.
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
