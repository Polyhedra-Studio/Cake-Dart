import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunner('Simple Test with no groups', [
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
              Expect.equals(expected: context.expected, actual: context.actual)
            ]),

    // isNotEqual expect
    Test<bool>(
      'IsNotEqual, true is not false',
      assertions: (test) =>
          [Expect.isNotEqual(actual: true, notExpected: false)],
    ),

    // isNull expect
    Test<bool>('IsNull, null is null',
        actual: null, assertions: (context) => [Expect.isNull(context.actual)]),

    // isNotNull expect
    Test<bool>('IsNotNull, true is not null',
        actual: true,
        assertions: (context) => [Expect.isNotNull(context.actual)]),

    // isType expect
    Test<bool>('IsType, true is bool',
        actual: true,
        assertions: (context) => [Expect<bool>.isType(context.actual)]),

    GroupWithContext<_CustomIsTypeFoo, Context<_CustomIsTypeFoo>>(
      'Group With Context',
      [
        TestWithContext(
            'Inherited Type, is the same, CustomTypeFoo should be CustomTypeFoo',
            actual: _CustomIsTypeFoo(),
            assertions: (test) =>
                [Expect<_CustomIsTypeFoo>.isType(test.actual)]),
        TestWithContext(
            'Inherited Type, CustomTypeBar is a valid child of CustomTypeFoo',
            actual: _CustomIsTypeBar(),
            assertions: (test) =>
                [Expect<_CustomIsTypeBar>.isType(test.actual)]),
      ],
      contextBuilder: Context<_CustomIsTypeFoo>.new,
    ),
    // isTrue expect
    Test<bool>('IsTrue, true is true',
        actual: true, assertions: (test) => [Expect.isTrue(test.actual)]),
    // isFalse expect
    Test<bool>('IsFalse, false is false',
        actual: false, assertions: (test) => [Expect.isFalse(test.actual)]),
    // Other
    Test<bool>('Action can accept return type',
        action: (test) => true,
        assertions: (test) =>
            [Expect.equals(actual: test.actual, expected: true)]),
  ]);
}

class _CustomIsTypeFoo<T> {
  String foo = 'foo';
}

class _CustomIsTypeBar extends _CustomIsTypeFoo {
  String bar = 'bar';
}
