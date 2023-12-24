part of '../cake.dart';

class AssertPass extends AssertResult {
  @override
  void Function(String message) printer = Printer.pass;

  AssertPass();

  @override
  void report({int spacerCount = 0}) {
    return;
  }
}
