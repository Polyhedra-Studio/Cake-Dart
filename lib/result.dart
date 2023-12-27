part of '../cake.dart';

/// For better formatting when output by the [Printer]
mixin Result {
  abstract void Function(String message) printer;

  /// For best results, make this 3 characters
  abstract String childIndicator;
  String spacer = '';
  String formatMessage();

  void report({int spacerCount = 0}) {
    setSpacer(spacerCount: spacerCount);
    printer(spacer + formatMessage());
  }

  void setSpacer({int spacerCount = 0}) {
    for (int i = 0; i < spacerCount; i++) {
      if (i < spacerCount - 1) {
        spacer += '   ';
      } else {
        spacer += childIndicator;
      }
    }
  }
}
