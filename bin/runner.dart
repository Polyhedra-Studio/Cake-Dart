import 'dart:io';

import 'package:cake/helper/printer.dart';

import 'collector.dart';
import 'settings.dart';

class Runner {
  Runner._();
  static Runner runner = Runner._();
  factory Runner() => runner;

  Future<List<FileSystemEntity>> cakeFileList = _fetchFileList();

  static Future<List<FileSystemEntity>> _fetchFileList() {
    final Stream<FileSystemEntity> streamList =
        Directory.current.list(recursive: true);
    Stream<FileSystemEntity> cakeStreamList = streamList.where((event) {
      String filename = event.path.split('/').last;
      bool cakeFile = filename.endsWith('.cake.dart');
      return cakeFile;
    });

    return cakeStreamList.toList();
  }

  Future<void> run(CakeSettings settings) async {
    Collector collector = Collector();
    List<FileSystemEntity> fileList = await cakeFileList;

    Iterable<Future<void>> processes = fileList
        .where((file) => settings.fileFilter != null
            ? file.path.contains(settings.fileFilter!)
            : true)
        .map<Future<void>>((file) async {
      // If we're filtering by a keyword, this needs to be passed via define
      List<String> processArgs = settings.testFilter.toProperties();
      processArgs.add(file.path);

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
    collector.printMessage(settings.verbose);
    Printer.neutral(''); // This makes sure to clear out any color changes
    return;
  }
}
