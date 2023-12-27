<div align="center">
    <img src="https://github.com/Polyhedra-Studio/Cake-Dart-VS/blob/main/images/cake_logo.png?raw=true" alt="Cake Tester Logo" width="128" />
    <h1>Cake Test Runner for Dart & Flutter</h1>
    <a href="https://pub.dev/packages/cake"><img alt="Pub Version" src="https://img.shields.io/pub/v/cake" /></a>
    <a href="https://opensource.org/license/mpl-2-0/"><img src="https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg" alt="License: MPL 2.0" /></a>
    <p>The tiniest unit tester, built for Dart. Now supports Flutter! Grab the additional <a href="https://pub.dev/packages/cake_flutter">Cake_Flutter</a> package.</p>
    <p>Running this in VS Code? Install the <a href="https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs">Cake VS-Code extension</a> to run tests inside your IDE, snippets, and more.</p>
</div>

# Getting started
## Installing

### Dart

1. Install Cake test runner globally.

```
dart pub global activate cake
```

2. (Optional) Install the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs)

3. Add the `cake` package to your [dev dependencies](https://pub.dev/packages/cake/install).
```
dart pub add dev:cake
```

### Flutter

1. Install Cake test runner globally.

```
dart pub global activate cake
```

2. (Optional) Install the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs)

3. Add the `cake_flutter` package to your [dev dependencies](https://pub.dev/packages/cake_flutter/install). (This also includes the `cake` package.)
```
flutter pub add dev:cake_flutter
```

## Running
- Cake will search for anything that has .cake.dart for the file name in the directory that it's run in.

### Command Line
In the CLI in the directory that you want to run your tests in:
```
dart run cake
```

You can also [add flags](#flags) to run specific tests or view output from specific tests.

### VS Code
- Run or debug tests in the Test Explorer or directly in the files themselves. (See [Marketplace](https://marketplace.visualstudio.com/items?itemName=Polyhedra.cake-dart-vs) page for more details.)

## Writing unit tests

Let's start off with a quick example:

```dart
TestRunnerOf<String>('API Service Test', [
  Group('Get Hello World', [
    Test(
      'Response payload should return "Hello world" if successful',
      action: (test) async => APIService.getHelloWorld(),
      assertions: (test) => [
        Expect.equals(actual: test.actual, expected: 'Hello world'),
      ],
    ),
  ]),
]);
```

**For an expanded version, check out the example in `examples/test/api.cake.dart`.**

### Organization
Cake relies on a hierarchy to organize tests. All tests _must_ be wrapped in a TestRunner. From there, you can list Tests directly or further nest them into groups. It's recommended to have one TestRunner per file.

### Stages
Cake encourages developers to write clean, simple, atomic tests by defining separate stages for each test. You might recognize this from the "Arrange-Act-Assert" or "Given-When-Then" style of writing unit tests. Here, you could analogue this to "Setup-Action-Assertions" (with additional teardown if needed).

All stages can be written as asynchronous, if needed.

#### Setup & Teardown
Setup and teardown is inherited from parents to children tests and groups. So you can write your initial setup logic in the root TestRunner, and then run any specific set up later in a group or test to specifically arrange for that functionality being tested on. All setup is run before any action. All teardown is run after all assertions have completed, and will run regardless if any issues occurred during testing.

#### Action
The action stage is meant to highlight the action being taken to test the outcome. This would be something like clicking a button, sending an API call, or running a function. Just remember that only _one_ action can be run during a test. If you find that your action function is large or encompassing a lot of code, that is usually a sign that it needs to broken into multiple tests or into the setup function.

While often need, the action stage is not required. Often unit tests that validate the initial state will skip the action stage.

Action can return a value to be set to the "actual" value that can be later used in assertions.

#### Assertions
Assertions run after the action stage and return a list of [Expects](#expect-matches). That, when applicable, take an expected output and matches it against an actual outcome. There's no limitations on how many assertions you can run. By default, Cake will ignore the rest of the assertions after the first one fails. This can be turned off in [Options](#options).

### Context
Context is how information can be passed from stage to stage and is an inheritable object that is passed from parent to children. This is passed as an argument on each stage. By default, test has an `actual` value, an `expected` value, and an additional map to pass information through ad-hoc. The default Context is called by using the `TestRunnerDefault` constructor.

```dart
TestRunnerDefault('Simple Test with Default Context', [
    Test('True is true', assertions: (test) => [Expect.isTrue(true)]),
    Test('Foo is bar', action: (test) => test['foo'] = 'bar', assertions: (test) => [
      Expect.equals(actual: test['foo'], expected: 'bar')
    ]),
  ],
);
```

#### Context Typing
The Context class allows for a generic parameter to be passed in order to have `actual` and `expected` be a specific type. This can be very handy for quickly protecting against bad refactors on code. You can define the generic value by using `TestRunnerOf`, `GroupOf`, and `TestOf` constructors.

```dart
TestRunnerOf<String>('Foo tests', [
    // This test inherits Context<String>
    Test('actual should be foo', action: (test) => test.actual = 'foo', assertions: (test) => [
      Expect.equals(actual: test.actual, expected: 'foo')
    ]),
    // This test should error because actual is trying to be set
    // to something that is not a String.
    Test(
      'actual should be true',
      action: (test) => test.actual = true, // This line should error in the Dart complier
      assertions: (test) =>
          [Expect.equals(actual: test.actual, expected: true)],
    ),
  ],
);
```

#### Extending Context
It's encouraged to create a custom context to avoid losing typing information on mapped items and avoiding magic strings. On TestRunners, Groups, and Tests, a `contextBuilder` parameter is must be set when it's declared. Remember to also override `copyExtraParams` to set the extra parameters if passing information from parent to children.

```dart
TestRunner<ExtraContext>('Test Suite with Extra Context', [
  // Group has ExtraContext set as Context
  Group('Foo', 
    [
      // Test has ExtraContext set as Context
      Test('Foo is True', assertions: (test) => [
        Expect.isTrue(test.foo),
        Expect.isNull(test.bar),
      ]),
    ],
    setup: (test) {
      test.foo = true;
    },
  ),
  Group('Bar', 
    [
      Test('Bar is set', assertions: (test) => [
        Expect.isFalse(test.foo),
        Expect.isNotNull(test.bar),
      ]),
    ],
    setup: (test) {
      test.bar = Bar();
    },
  ),
  setup: (test) {
    test.bar = null;
  },
  contextBuilder: ExtraContext.new,
]);

// ....
class ExtraContext extends Context {
  bool foo = false;
  Bar? bar;

  @override
  void copyExtraParams(Context contextToCopyFrom) {
    if (contextToCopyFrom is ExtraContext) {
      bar = contextToCopyFrom.bar;
      foo = contextToCopyFrom.foo;
    }
  }
}

```

## Expect Matches
  - equals
  - isEqual **
  - isNotEqual
  - isNull
  - isNotNull
  - isType ***
  - isTrue
  - isFalse

** equals and isEqual can be used interchangeably.

*** isType will need a generic defined or else it will always pass as true as it thinks the type is `dynamic`.


## Options
Options are an inheritable object that can be set on a TestRunner, Group, or Test. Any child settings will override parent settings, if set.

- `failOnFirstExpect` - Default: `true`
  - Set the flag to false to have Cake run all assertions regardless if one of them fails or not.

```dart
TestRunnerDefault('Test Options', [
  Test(
    'Should report only one failure by default',
    assertions: (test) => [
      Expect.equals(actual: true, expected: false), // This test will fail and Cake will bail on the rest of the asserts.
      Expect.isTrue(true), // This one is meant to pass, but will be skipped
    ],
  ),
  Test(
    'Should report only one failure when failOnFirstExpect is true',
    assertions: (test) => [
      Expect.equals(actual: true, expected: false), // This test will fail, but Cake is set to continue
      Expect.isTrue(true), // This one is meant to pass and will show as passed in results.
    ],
    options: const TestOptions(failOnFirstExpect: true),
  ),
  options: const TestOptions(failOnFirstExpect: false),
);
```

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

### Interactive mode
- `-i`
  - Allows for repeatedly running tests. You can also use the test filters similar to non-interactive mode's syntax.

### Flutter mode
- `--flutter`
  - Forces Cake to run in Flutter mode regardless of imports. Cake otherwise will automatically try to detect if the [cake_flutter](https://pub.dev/packages/cake_flutter) package has been imported.

# Feedback
If you discover a bug or have a suggestion, please check [Issues](https://github.com/Polyhedra-Studio/Cake-Dart/issues) page. If someone has already submitted your bug/suggestion, please upvote so it can get better visibility.

# License
This extension is licensed under Mozilla Public License, 2.0.