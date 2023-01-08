import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunner('Test Runner Cake Test', [
    Group('Runs a group', [
      Test('Test in a group runs',
          action: (test) => true,
          assertions: (test) => [
                Expect.isTrue(test.actual),
              ]),
    ]),
    Group('Runs a nest group, parent', [
      Group('Runs a nested group, child', [
        Test(
          'Test in a nested group runs',
          action: (test) => true,
          assertions: (test) => [
            Expect.isTrue(test.actual),
          ],
        ),
      ]),
    ]),
    Test(
      'Individual test runs',
      action: (test) => true,
      assertions: (test) => [
        Expect.isTrue(test.actual),
      ],
    ),
  ]);
}
