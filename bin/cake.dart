import 'dart:io';

import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  // Search for all files in this directory that end with _cake or .cake in them
  Stream<FileSystemEntity> streamList = Directory.current.list(recursive: true);
  Stream<FileSystemEntity> cakeStreamList = streamList.where((event) {
    String filename = event.path.split('/').last;
    return filename.endsWith('.cake.dart');
  });

  List<FileSystemEntity> cakeList = await cakeStreamList.toList();
  if (cakeList.isEmpty) {
    return TestMessage('Cake Test Runner',
            message:
                'No tests found in this directory. Cake tests should end with ".cake.dart"')
        .report();
  }

  // Run all the runners
  for (FileSystemEntity cakeTest in cakeList) {
    Process.run('dart', [cakeTest.path]).then((ProcessResult result) {
      if (result.stderr is String && result.stderr.isNotEmpty) {
        print(result.stderr);
      }
      print(result.stdout);
    });
  }
}
