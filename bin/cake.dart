import 'dart:io';

import 'package:cake/cake.dart';
import 'runner.dart';
import 'settings.dart';

void main(List<String> arguments) async {
  final CakeSettings settings = CakeSettings(arguments);
  final Runner runner = Runner();

  final List<FileSystemEntity> cakeList = await runner.cakeFileList;
  if (cakeList.isEmpty) {
    return TestMessage('Cake Test Runner',
            message:
                'No tests found in this directory. Cake tests should end with ".cake.dart"')
        .report();
  }

  if (!settings.interactive) {
    await runner.run(settings);
    return;
  }

  // [Interactive mode]
  bool shouldContinue = true;
  const String promptMessage =
      'Cake Tester is in interactive mode. Type "e" or "exit" to exit, "h" or "help" for more options.';
  const String testsCompleteMessage = '---Tests Complete---';
  if (!settings.isVsCode) {
    print(promptMessage);
  }

  while (shouldContinue) {
    final String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      if (!settings.isVsCode) {
        print('Running all tests...');
      }

      await runner.run(CakeSettings([]));

      if (!settings.isVsCode) {
        print(testsCompleteMessage);
        print('');
        print(promptMessage);
      }
      continue;
    }

    if (input == 'exit' || input == 'e') {
      shouldContinue = false;
      continue;
    }

    if (input == 'help' || input == 'h') {
      print('''
To run all tests, just press return.
To run specific tests, interactive mode supports similar flags to non-interactive mode followed by the search criteria.
  -t    General search:     -t foo             Run all tests, groups, and runners with "foo" in the title
  --tt  Test search:        --tt cool test   Run all tests with the phrase "cool test" in the title
  --tte Test search, exact: --tte should only pass when true      Runs only the test that matches the phrase exactly.
  --tg  Group search:       --tg bar           Run all groups matching "bar" in the title
  --tge Group search, exact:--tge API Endpoints     Runs all groups exactly matching the phrase "API Endpoints"
  --tr  Test Runner search: --tr Models      Runs all test runners with "Models" in the title
  --tre Test Runner search, exact: --tre Models - User      Runs test runners that exactly match the phrase "Models - User" 
''');
      continue;
    }

    final RegExp flagMatch = RegExp(r'^(-t|--t[tgr]e?)\s(.*)');
    if (flagMatch.hasMatch(input)) {
      final match = flagMatch.firstMatch(input);
      if (match != null) {
        final String? flag = match.group(1);
        final String? input = match.group(2);

        if (flag != null && input != null) {
          final CakeSettings inputSettings = CakeSettings([flag, input]);
          await runner.run(inputSettings);
          if (!settings.isVsCode) {
            print(testsCompleteMessage);
            print('');
            print(promptMessage);
          }
          continue;
        }
      }
    }

    print('Could not recognize input. Try again.');
  }
}
