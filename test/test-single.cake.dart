import 'package:cake/expect.dart';
import 'package:cake/test.dart';

void main(List<String> arguments) async {
  [
    // Generic Constructor
    Test<bool>.single('True is true - shorthand', expected: true, actual: true),
    Test<bool>.single('True is true - assertion',
        assertions: ((context) => [
              Expect(ExpectType.equals, expected: true, actual: true),
            ])),
    Test<bool>.single(
      'True is true, set in setup',
      setup: (context) {
        context.expected = true;
        context.actual = true;
      },
    ),
    Test<bool>.single(
      'True is true, set in action',
      action: (context) {
        context.expected = true;
        context.actual = true;
      },
    ),

    // Equals expect
    Test<bool>.single('Equals, true is true',
        expected: true,
        actual: true,
        assertions: (context) => [
              Expect.equals(expected: context.expected, actual: context.actual)
            ]),

    // isNull expect
    Test<bool>.single('IsNull, null is null',
        actual: null,
        assertions: (context) => [Expect.isNull(actual: context.actual)]),

    // isNotNull expect
    Test<bool>.single('IsNotNull, true is not null',
        actual: true,
        assertions: (context) => [Expect.isNotNull(actual: context.actual)]),

    // isType expect
    Test<bool>.single('IsType, true is bool',
        actual: true,
        assertions: (context) => [Expect.isType(actual: context.actual)]),
  ];
}
