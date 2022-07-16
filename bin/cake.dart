import 'dart:io';

import 'package:cake/cake.dart';
import 'package:cake/helper/printer.dart';

import 'collector.dart';
import 'runner.dart';
import 'settings.dart';

void main(List<String> arguments) async {
  CakeSettings settings = CakeSettings(arguments);
  Runner runner = Runner();

  List<FileSystemEntity> cakeList = await runner.cakeFileList;
  if (cakeList.isEmpty) {
    return TestMessage('Cake Test Runner',
            message:
                'No tests found in this directory. Cake tests should end with ".cake.dart"')
        .report();
  }

  if (!settings.interactive) {
    Collector collector = await runner.run(settings);

    // Print results
    collector.printMessage(settings.verbose);
    Printer.neutral(''); // This makes sure to clear out any color changes
    return;
  }

  // Interactive mode
}
