import 'package:cake/expect.dart';
import 'package:cake/test.dart';

void main(List<String> arguments) async {
  [
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
  ];
}
