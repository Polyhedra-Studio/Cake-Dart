import 'package:cake/cake.dart';

void main(List<String> arguments) async {
  TestRunnerDefault('Simple Test with no groups', [
    // Generic Constructor
    Test(
      'True is true - assertion',
      assertions: ((context) => [
            Expect(ExpectType.equals, expected: true, actual: true),
          ]),
    ),
    Test(
      'True is true, set in setup',
      setup: (context) {
        context.expected = true;
        context.actual = true;
      },
      assertions: (test) => [Expect.isTrue(test.actual)],
    ),
    Test(
      'True is true, set in action',
      action: (test) {
        test.expected = true;
        test.actual = true;
      },
      assertions: (test) => [Expect.isTrue(test.actual)],
    ),

    // Equals expect
    Test(
      'Equals, true is true',
      action: (test) {
        test.actual = true;
        test.expected = true;
      },
      assertions: (context) => [
        Expect.equals(expected: context.expected, actual: context.actual),
      ],
    ),

    // isNotEqual expect
    Test(
      'IsNotEqual, true is not false',
      assertions: (test) =>
          [Expect.isNotEqual(actual: true, notExpected: false)],
    ),

    // isNull expect
    Test(
      'IsNull, null is null',
      action: (test) => null,
      assertions: (context) => [Expect.isNull(context.actual)],
    ),

    // isNotNull expect
    Test(
      'IsNotNull, true is not null',
      action: (test) => true,
      assertions: (context) => [Expect.isNotNull(context.actual)],
    ),

    // isType expect
    Test(
      'IsType, true is bool',
      action: (test) => true,
      assertions: (context) => [Expect<bool>.isType(context.actual)],
    ),

    Group<Context<_CustomIsTypeFoo>>(
      'Group With Context',
      [
        Test(
          'Inherited Type, is the same, CustomTypeFoo should be CustomTypeFoo',
          action: (test) => _CustomIsTypeFoo(),
          assertions: (test) => [Expect<_CustomIsTypeFoo>.isType(test.actual)],
        ),
        Test(
          'Inherited Type, CustomTypeBar is a valid child of CustomTypeFoo',
          action: (test) => _CustomIsTypeBar(),
          assertions: (test) => [Expect<_CustomIsTypeBar>.isType(test.actual)],
        ),
      ],
      contextBuilder: Context<_CustomIsTypeFoo>.new,
    ),
    // isTrue expect
    Test(
      'IsTrue, true is true',
      action: (test) => true,
      assertions: (test) => [Expect.isTrue(test.actual)],
    ),
    // isFalse expect
    Test(
      'IsFalse, false is false',
      action: (test) => false,
      assertions: (test) => [Expect.isFalse(test.actual)],
    ),
    // Other
    Test(
      'Action can accept return type',
      action: (test) => true,
      assertions: (test) =>
          [Expect.equals(actual: test.actual, expected: true)],
    ),
  ]);
}

class _CustomIsTypeFoo<T> {
  String foo = 'foo';
}

class _CustomIsTypeBar extends _CustomIsTypeFoo {
  String bar = 'bar';
}
