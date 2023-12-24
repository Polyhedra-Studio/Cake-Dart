part of '../cake.dart';

class AssertNeutral extends AssertResult {
  @override
  void Function(String message) printer = Printer.neutral;

  AssertNeutral({super.message, super.index});
}
