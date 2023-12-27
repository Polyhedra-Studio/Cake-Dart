part of '../cake.dart';

/// Returned if an [Expect] is never ran or is inconclusive.
///
/// Likely case is when an assertion before an [Expect] fails. Note that you can
/// turn off this behavior by setting [TestOptions.failOnFirstAssert] to false.
class AssertNeutral extends AssertResult {
  @override
  void Function(String message) printer = Printer.neutral;

  AssertNeutral({super.message, super.index});
}
