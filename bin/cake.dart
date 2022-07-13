import 'dart:io';

import 'package:cake/cake.dart';
import 'package:cake/helper/printer.dart';

import 'collector.dart';
import 'settings.dart';

void main(List<String> arguments) async {
  CakeSettings settings = CakeSettings(arguments);

  // Search for all files in this directory that end with _cake or .cake in them
  Stream<FileSystemEntity> streamList = Directory.current.list(recursive: true);
  Stream<FileSystemEntity> cakeStreamList = streamList.where((event) {
    String filename = event.path.split('/').last;
    bool cakeFile = filename.endsWith('.cake.dart');
    if (cakeFile && settings.fileFilter != null) {
      return filename.contains(settings.fileFilter!);
    }
    return cakeFile;
  });

  List<FileSystemEntity> cakeList = await cakeStreamList.toList();
  if (cakeList.isEmpty) {
    return TestMessage('Cake Test Runner',
            message:
                'No tests found in this directory. Cake tests should end with ".cake.dart"')
        .report();
  }

  Collector collector = Collector();

  // Run all the runners
  Iterable<Future<void>> processes =
      cakeList.map<Future<void>>((cakeTest) async {
    // If we're filtering by a keyword, this needs to be passed via define
    List<String> processArgs = settings.testFilter.toProperties();
    processArgs.add(cakeTest.path);

    return Process.run('dart', processArgs).then((ProcessResult result) {
      if (result.stderr is String && result.stderr.isNotEmpty) {
        print(result.stderr);
      }
      List<TestRunnerCollector> testRunnerCollectors =
          testRunnerOutputParser(result.stdout);
      for (TestRunnerCollector element in testRunnerCollectors) {
        collector.addCollector(element);
      }

      if (settings.verbose) {
        print('${collector.total} tests found...');
      }
    });
  });

  await Future.wait(processes);

  // Print results
  collector.printMessage(settings.verbose);
  Printer.neutral(''); // This makes sure to clear out any color changes
}
