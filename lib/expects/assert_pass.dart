part of '../cake.dart';

/// Returned after an [Expect] has succeeded.
class AssertPass extends AssertResult {
  @override
  void Function(String message) printer = Printer.pass;

  AssertPass();

  @override
  void report({int spacerCount = 0}) {
    return;
  }
}
