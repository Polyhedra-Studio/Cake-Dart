import 'package:cake/cake.dart';

void main() {
  TestRunnerDefault('Test Runner - Basic', [
    Group('Group - Basic', [
      Test(
        'True should be true',
        assertions: (test) => [Expect.isTrue(true)],
      ),
    ]),
  ]);
}
