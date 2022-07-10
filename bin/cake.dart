import 'dart:io';

import 'package:cake/cake.dart';

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
