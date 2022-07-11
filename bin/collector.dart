import 'package:cake/helper/printer.dart';

class Collector {
  List<TestRunnerCollector> collectors = [];
  int total = 0;
  int successes = 0;
  int failures = 0;
  int neutrals = 0;

  void addCollector(TestRunnerCollector collector) {
    collectors.add(collector);
    total += collector.total;
    successes += collector.successes;
    failures += collector.failures;
    neutrals += collector.neutrals;
  }

  void printMessage(bool verbose) {
    String summary = Printer.summary(
        total: total,
        successes: successes,
        failures: failures,
        neutrals: neutrals);

    if (failures > 0) {
      Printer.fail(summary);
    } else if (successes == 0) {
      Printer.neutral(summary);
    } else {
      Printer.pass(summary);
    }

    if (verbose) {
      for (var element in collectors) {
        element.printMessage();
      }
    }
  }
}

class TestRunnerCollector {
  List<String> testOutput;
  List<String> summary;
  int total;
  int successes;
  int failures;
  int neutrals;
  int endIndex;

  TestRunnerCollector(
    this.testOutput,
    this.summary, {
    required this.total,
    required this.successes,
    required this.failures,
    required this.neutrals,
    required this.endIndex,
  });

  void printMessage() {
    // This already has formatting from the printer, just pass through the original message
    for (String element in testOutput) {
      print(element);
    }
  }
}

List<TestRunnerCollector> testRunnerOutputParser(String stdout) {
  List<TestRunnerCollector> testRunnerOutputs = [];
  List<String> lines = stdout.split('\n');
  int index = 0;
  while (index < lines.length - 1) {
    TestRunnerCollector testRunnerCollector =
        _testRunnerOutputParser(lines, index);
    testRunnerOutputs.add(testRunnerCollector);
    index = testRunnerCollector.endIndex;
  }

  return testRunnerOutputs;
}

TestRunnerCollector _testRunnerOutputParser(
    List<String> lines, int startingIndex) {
  List<String> testOutput = [];
  List<String> summary = [];
  int total = 0;
  int successes = 0;
  int failures = 0;
  int neutrals = 0;
  int atSummaryLine = -1;
  const String summaryLine = ' - Summary: ---------------';
  RegExp totalLine = RegExp(r'(\d*) tests ran\.');
  RegExp successLine = RegExp(r'(\d*) passed\.');
  RegExp failedLine = RegExp(r'(\d*) failed\.');
  RegExp neutralLine = RegExp(r'(\d*) skipped\/inconclusive\.');
  int i = startingIndex;
  for (i; (i < lines.length - 1 || atSummaryLine == 7); i++) {
    String line = lines[i];

    if (line.contains(summaryLine)) {
      atSummaryLine = 0;
    }

    switch (atSummaryLine) {
      case 2:
        // Total
        total = _getValueFromRegExLine(totalLine, line) ?? 0;
        break;
      case 3:
        // Passed
        successes = _getValueFromRegExLine(successLine, line) ?? 0;
        break;
      case 4:
        // Failed
        failures = _getValueFromRegExLine(failedLine, line) ?? 0;
        break;
      case 5:
        // Neutral
        neutrals = _getValueFromRegExLine(neutralLine, line) ?? 0;
        break;
      case 6:
        // All dash
        break;
      case 7:
      // Empty space between summaries. Should break out of the loop after this.
      // Others
      default:
        break;
    }

    if (atSummaryLine > -1) {
      summary.add(line);
      atSummaryLine++;
    } else {
      testOutput.add(line);
    }
  }

  return TestRunnerCollector(
    testOutput,
    summary,
    total: total,
    successes: successes,
    failures: failures,
    neutrals: neutrals,
    endIndex: i,
  );
}

int? _getValueFromRegExLine(RegExp regExp, String line) {
  RegExpMatch? matches = regExp.firstMatch(line);
  if (matches != null && matches.group(1) != null) {
    return int.tryParse(matches.group(1)!);
  }
  return null;
}
