import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunner('Test Groups', [
    Group('Should run all children tests', children: [
      // Generic Constructor
      Test<bool>('True is true - shorthand', expected: true, actual: true),
      Test<bool>('True is true - assertion',
          assertions: ((context) => [
                Expect(ExpectType.equals, expected: true, actual: true),
              ])),
      Test<bool>(
        'True is true, set in setup',
        setup: (context) {
          context.expected = true;
          context.actual = true;
        },
      ),
      Test<bool>(
        'True is true, set in action',
        action: (context) {
          context.expected = true;
          context.actual = true;
        },
      ),

      // Equals expect
      Test<bool>('Equals, true is true',
          expected: true,
          actual: true,
          assertions: (context) => [
                Expect.equals(
                    expected: context.expected, actual: context.actual)
              ]),

      // isNull expect
      Test<bool>('IsNull, null is null',
          actual: null,
          assertions: (context) => [Expect.isNull(actual: context.actual)]),

      // isNotNull expect
      Test<bool>('IsNotNull, true is not null',
          actual: true,
          assertions: (context) => [Expect.isNotNull(actual: context.actual)]),

      // isType expect
      Test<bool>('IsType, true is bool',
          actual: true,
          assertions: (context) => [Expect.isType(actual: context.actual)]),
    ]),
    Group(
      'Nested Group - Parent',
      children: [
        Group(
          'Nested Group - Child',
          children: [
            Test<bool>('Nested test should pass', expected: true, actual: true),
          ],
        ),
      ],
    )
  ]);
}
