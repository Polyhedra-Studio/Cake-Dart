import 'dart:math';

class Printer {
  static void pass(String message) {
    print('\x1B[32m$message\x1B[0m');
  }

  static void fail(String message) {
    print('\x1B[31m$message\x1B[0m');
  }

  static void neutral(String message) {
    print('\x1B[90m$message\x1B[0m');
  }

  static String summary({
    required int total,
    required int successes,
    required int failures,
    required int neutrals,
  }) {
    final int totalCharCount = total.toString().length;
    final int successCharCount = successes.toString().length;
    final int failureCharCount = failures.toString().length;
    final int neutralCharCount = neutrals.toString().length;
    final int maxCharCount = [
      totalCharCount,
      successCharCount,
      failureCharCount,
      neutralCharCount,
    ].fold<int>(1, (previousValue, element) => max(previousValue, element));

    const int baseTopDashSpacer = 18;
    const int baseBlankSpacer = 28;
    const int baseTotalSpacer = 14;
    const int baseSuccessSpacer = 15;
    const int baseFailureSpacer = 15;
    const int baseNeutralSpacer = 1;
    const int boxLength = 29;

    final int totalExtraSpace = maxCharCount - totalCharCount + baseTotalSpacer;
    final int successExtraSpace =
        maxCharCount - successCharCount + baseSuccessSpacer;
    final int failureExtraSpace =
        maxCharCount - failureCharCount + baseFailureSpacer;
    final int neutralExtraSpace =
        maxCharCount - neutralCharCount + baseNeutralSpacer;

    // There are only two fields that might realistically overflow the box
    // - total and neutrals. Since total will always be >= passed and failed
    // count, we can just look at total and push out the space from there.
    int allExtraSpace = 0;
    if (neutralExtraSpace == maxCharCount && maxCharCount > baseNeutralSpacer) {
      allExtraSpace = maxCharCount - baseNeutralSpacer;
    } else if (totalExtraSpace == maxCharCount &&
        maxCharCount > baseTotalSpacer) {
      allExtraSpace = maxCharCount - baseTotalSpacer;
    }

    /*
     * Create a box that looks like this:
     * - Summary: -------------------
     * |                            |
     * |  $total tests ran.              |
     * |  - $successes passed.               |
     * |  - $failures failed.               |
     * |  - $neutrals skipped/inconclusive. |
     * -------------------------------
     */

    String message = '\n';
    // - Summary: -------------------
    message += ' - Summary: ';
    for (int i = 1; i < baseTopDashSpacer + allExtraSpace; i++) {
      message += '-';
    }
    message += '\n';

    // |                            | (blank spacer line)
    message += '|';
    for (int i = 1; i < baseBlankSpacer + allExtraSpace; i++) {
      message += ' ';
    }
    message += '|\n';

    // |  $total tests ran.              |
    message += '|  $total tests ran.';
    for (int i = 1; i < totalExtraSpace + allExtraSpace; i++) {
      message += ' ';
    }
    message += '|\n';

    // |  - $successes passed.               |
    message += '|  - $successes passed.';
    for (int i = 1; i < successExtraSpace + allExtraSpace; i++) {
      message += ' ';
    }
    message += '|\n';

    // |  - $failures failed.               |
    message += '|  - $failures failed.';
    for (int i = 1; i < failureExtraSpace + allExtraSpace; i++) {
      message += ' ';
    }
    message += '|\n';

    // |  - $neutrals skipped/inconclusive. |
    message += '|  - $neutrals skipped/inconclusive.';
    for (int i = 1; i < neutralExtraSpace + allExtraSpace; i++) {
      message += ' ';
    }
    message += '|\n';

    // -------------------------------
    message += ' ';
    for (int i = 1; i < boxLength + allExtraSpace; i++) {
      message += '-';
    }
    message += '\n';

    return message;
  }
}
