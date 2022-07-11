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
  isType, **
  isTrue,
  isFalse,
}

** isType will need a generic defined or else it will always pass as true as it thinks the type is `dynamic`.

# How to run the test runner
- The package will need to run globally. Install via this command:
`dart pub global activate cake --hosted-url http://butterfree.lan:30117`
- After it's installed, you can run it by using `dart run cake` in the directory that you want to run your tests in. It will search any files in the directory or any sub-folders ending with `cake.dart`.
- You can also add flags to run specific tests or view output from specific tests.

## Flags

### File name filter
- `-f [fileName]`
  - Filters tests based off of file name
  - EX: `dart run cake -f foo` will test 'test-foo.cake.dart'

### Verbose mode
- `-v` or `--verbose`
  - Displays full output of summary and tests run

### Test Filter
- `-t [testFilter]`, `--tt [testFilter]`, `--tte [testName]`,  `--tg [groupFilter]`, `--tge [groupName]`, `--tr [testRunnerFilter]`, `--tre [testRunnerName]`
  - All of these do similar things, which filters based off of title of the item. You can also use certain tags to run only a group, test runner, or a specific test.
  - Note - search is case-sensitive.
  - Examples: 
    - `-t` **General search:** `dart run cake -t foo` - Run all tests, groups, and runners with "foo" in the title
    - `--tt` **Test search** `dart run cake --tt "cool test"` - Run all tests with the phrase "cool test" in the title
    - `--tte` **Test search, exact:** `dart run cake --tte "should only run when this one specific thing happens"` - Runs only the test that matches the phrase exactly.
    - `--tg` **Group search** `dart run cake --tg bar` - Run all groups matching "bar" in the title
    - `--tge` **Group search, exact:** `dart run cake --tge "API Endpoints" - Runs all groups _exactly_ matching the phrase "API Endpoints"
    - `--tr` **Test Runner search:** `dart run cake --tr "Models" - Runs all test runners with "Models" in the title
    - `--tre` **Test Runner search, exact:** `dart run cake --tre "Models - User"` - Runs test runners that _exactly_ match the phrase "Models - User" 