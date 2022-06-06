# Cake
The tiniest unit tester, built for dart

# How to write unit tests
- Cake will search for anything that has .cake.test for the file name in the directory that it's run in
- Example of how to write unit tests:
```dart
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
```

# Expect Matches
enum ExpectType {
  equals,
  isNull,
  isNotNull,
  isType,
}

Use the constructor to specify the type. isType will need a generic defined or else it will always pass as true.

# How to run test runner
- The package will need to run globally. Install via this command:
`dart pub global activate cake --hosted-url http://butterfree.lan:30117`
