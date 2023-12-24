part of '../cake.dart';

abstract class AssertResult with Result {
  String? message;
  int? index;
  @override
  String childIndicator = '  |';

  AssertResult({this.message, this.index});

  @override
  String formatMessage() {
    // Asserts will always be indented, thus the 4 spaces here
    if (index == null) {
      return '  $message';
    } else {
      return '  [#$index] $message';
    }
  }

  @override
  void setSpacer({int spacerCount = 0}) {
    super.setSpacer(spacerCount: spacerCount);
    spacer = '  $spacer';
  }
}
