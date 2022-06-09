import 'package:cake/group.dart';
import 'package:cake/test.dart';
import 'package:cake/test_runner.dart';

void main(List<String> arguments) async {
  TestRunner('Test Runner Cake Test', [
    Group('Runs a group', children: [
      Test('Test in a group runs', actual: true, expected: true),
    ]),
    Group('Runs a nest group, parent', children: [
      Group('Runs a nested group, child', children: [
        Test('Test in nested group runs', expected: true, actual: true),
      ]),
    ]),
    Test('Individual test runs', actual: true, expected: true),
  ]);
}
