import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunner('Test Runner Cake Test', [
    Group('Runs a group', [
      Test('Test in a group runs', actual: true, expected: true),
    ]),
    Group('Runs a nest group, parent', [
      Group('Runs a nested group, child', [
        Test('Test in nested group runs', expected: true, actual: true),
      ]),
    ]),
    Test('Individual test runs', actual: true, expected: true),
  ]);
}
