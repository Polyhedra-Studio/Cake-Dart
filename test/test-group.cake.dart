import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunnerDefault('Test Groups', [
    Group('Should run all children tests', [
      Test(
        'True is true, set in setup',
        setup: (context) {
          context.expected = true;
          context.actual = true;
        },
        assertions: (test) => [
          Expect.equals(actual: test.expected, expected: test.actual),
        ],
      ),
      Test(
        'True is true, set in action',
        action: (context) {
          context.expected = true;
          context.actual = true;
        },
        assertions: (test) => [
          Expect.equals(actual: test.expected, expected: test.actual),
        ],
      ),

      // Equals expect
      Test(
        'Equals, true is true',
        setup: (test) {
          test.expected = true;
        },
        action: (test) {
          test.actual = true;
        },
        assertions: (context) => [
          Expect.equals(
            expected: context.expected,
            actual: context.actual,
          ),
        ],
      ),

      // isNull expect
      Test(
        'IsNull, null is null',
        action: (test) {
          test.actual = null;
        },
        assertions: (context) => [Expect.isNull(context.actual)],
      ),

      // isNotNull expect
      Test(
        'IsNotNull, true is not null',
        action: (test) {
          test.actual = true;
        },
        assertions: (context) => [Expect.isNotNull(context.actual)],
      ),

      // isType expect
      Test(
        'IsType, true is bool',
        action: (test) {
          test.actual = true;
        },
        assertions: (context) => [Expect.isType(context.actual)],
      ),
    ]),
    Group('Nested Group - Parent', [
      Group('Nested Group - Child', [
        Test(
          'Nested test should pass',
          action: (test) {
            test.expected = true;
            test.actual = true;
          },
          assertions: (test) => [
            Expect.equals(actual: test.actual, expected: test.expected),
          ],
        ),
      ]),
    ]),
  ]);
}
