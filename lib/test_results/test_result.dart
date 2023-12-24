part of '../cake.dart';

abstract class _TestResult with Result {
  String testTitle;
  // The extra space before the dropdown arrow is to point to the middle
  // of the [X], (0), or (-) of the parent.
  @override
  String childIndicator = ' `-';

  _TestResult(this.testTitle);
}
