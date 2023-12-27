## 6.0.0 (2023-12-27)
- [ADD][CLI] Added support for [Cake-Flutter](https://github.com/Polyhedra-Studio/Cake-Flutter)
- [ADD][CLI] Added --flutter flag to force Cake to run in Flutter test mode. This is only needed if the cake_flutter package is not directly imported.
- [META] Added example folder with `api.cake.dart` example to show a full semi-realistic version of a test suite.
- [META] Improved README.md with better formatting for header, more examples, and instructions for Flutter.
- [META] Added more dartdoc comments on common outward-facing classes.

## 5.5.2 (2023-12-24)
- [MOD][Expect] Made .run() public.

## 5.5.1 (2023-12-24)
- [FIX][CLI] Fixed reporting not showing individual failing tests when there's more than one test runner in a file.
- [MOD][Reporter] Made formatting more consistent between assertions. Changed formatting to use a pipe instead of the standard ascii dropdown to make results a bit cleaner.
- [MOD][Reporter] When an asynchronous test is run synchronously, it will now consider the test as failing rather than inconclusive. (Technically, "inconclusive" is the correct word since hasn't received a pass/fail yet, however this happening is usually an error that should indicate that something has gone wrong.)
- [MOD][Reporter] More consistent messaging when an assert fails with a critical error.
- [FIX][Reporter] Fixed indentation on groups.
- [FIX] Refactored TestResult to expose AssertResults to allow for custom Expects to be written. This also better matches what's in [Cake-Ruby](https://github.com/Polyhedra-Studio/Cake-Ruby) as well.

## 5.5.0 (2023-12-24)
- [ADD][Expect] Added the .isEqual expect type. This works exactly as the .equals expect type.
- [MINOR-BREAKING] Removed the `Expect(ExpectType)` style constructor for expects. This generally was not being used and was stopping the Expect class from being expandable for other type of Expects. This also now mirrors the [Cake-Ruby](https://github.com/Polyhedra-Studio/Cake-Ruby) style for better maintainability between the two libraries.

## 5.4.0 (12-22-2023)
- [ADD][TestRunner] Added setup and teardown stages to TestRunner. Originally this was intentionally left out to encourage creating one TestRunner per file and having Groups be the controller of setup and teardown, but the end result did not have that effect. Instead it just forced making one massive parent group that had a lot of duplication with the parent TestRunner. The rules around one TestRunner per file have relaxed anyways (there's examples in this repo, even) so the point was very moot.
- [ADD][TestRunner] Added a OnComplete hook to TestRunner that fires a callback with test results in a string, if any. 

## 5.3.0 (12-22-2023)
- [ADD] Added a more helpful error message when Context building fails.
- [FIX] Context is now built from top down (TestRunner -> Group -> Test), like one would intuitively expect rather than building the children and then building the parents. In rare cases, this was causing bugs for very complex or async test setups.
- [MOD] Context should now only be built once for each item. This should help a little bit with performance with larger test runners. (O(n) vs O(n!), n being the number of items in a test runner.)
- [MOD] Cleanup and simplification around context assignment under the hood. May have very minor performance boosts.

## 5.2.0 (12-21-2023)
- [ADD] ContextBuilder can now be run asynchronously, if needed.

## 5.1.0 (12-19-2023)
- [ADD][CLI] Added Help flag (`-h` or `--help`) to show help in non-interactive mode
- [MOD][CLI] Interactive mode can also be turned on with the `--interactive` flag (previously just `-i` before)
- [FIX] Setup error during Group setup stage no longer throws null error by trying to report children.
- [MOD] Very minor cleanup of error responses.
- [META] Readme cleaned up of some old data

## 5.0.2
- [PKG] Moved lint to use shared PH lint library
- [MOD] Updates styling to match new rules.

## 5.0.1
- [FIX] Fixed a bug where tests without a group would still run if groups were filtered.

## 5.0.0
- [BREAKING] Updated minimum Dart version to 2.17.0
- [ADD] Added the skip constructor to all tests, groups, and TestRunners. When using skip, no code will be run within that object and all it's children - meaning setup/teardown is not called.
- [MOD] Stubbed tests will also display a skip message (treated the same was as skip).
- [FIX] Fixed isNotNull error message from not displaying the error'd object.
- [META] Added new linting rules to bring in line with other projects
- [META] Updated License to use MPL-2.0
- [BREAKING] Removed <ExpectedType, Context<ExpectedType>> on the Test class as it wasn't actually being effective and was quite wordy. This has been replaced with the TestOf<ExpectedType> constructor. This should be a much simpler way to declare a test a simple object.
- [BREAKING] Removed GroupDefault as of some revisions ago it was no longer useful over just using Group.
- [ADD] Added GroupOf<ExpectedType> that works similar to TestOf.
- [ADD] Added TestRunnerOf<ExpectedType> that works similar to TestOf.

## 4.0.0
- [BREAKING] Removed Expected type from TestRunner and Groups. This wasn't being used a whole lot and felt really redundant when TestRunnerWithContext is used pretty extensively.
- [BREAKING] Removed {Object}WithContext in favor of just using `{Object}Default` when a context is not used and `{Object}<Context>` when it is. More often than not, a custom context is used with tests, an in the case there isn't, a context object is setup by default, which will hopefully make it easier to follow. Hopefully this will also make tests less wordy.
- [BREAKING] Removed the default expected and actual from being set in groups. Again, wasn't used a whole lot and often breaks because of context issues.
- [BREAKING] By default, tests will fail on the first expect failure rather than try to run through all. This can be turned off with the options object.
- [BREAKING] Assertion steps in tests are REQUIRED in non-stubbed tests. This is to encourage good behavior and smaller surface area of tests to maintain what with default assertions and all.
- [MOD] Renamed T to ExpectedType and C to {Object}Context to clarify which class is being declared
- [ADD] Added options parameter to TestRunners, Groups, and Tests to with the option to declare when a test should fail on first expect failure or run through all.
- [ADD] Added stub constructor to tests that allows for not inserting an assertions.

## 3.5.0
- [ADD] Added Expect.isNotEqual

## 3.4.8
- [FIX] Expect<T>.isType should ignore any test or group typing for test.actual. As in, if actual is meant to be class Foo, and you want to check if it's class Bar, it should be valid to check Expect<Bar>(test.actual). This is a valid case in inherited classes that dart would normally throw an error for.

## 3.4.7
- [ADD] Expects will report which exact expect failed if there are multiple expects in a test

## 3.4.6
- [FIX] Fixed teardown not running when using XWithContext tests and groups 

## 3.4.5
- [FIX] Fixed a context error when using non XWithContext tests

## 3.4.4
- [QoL] Errors that happen during the context assignment phase will have a more accurate message and stack trace.
- [FIX] Fixed summary not reporting correct numbers with xWithContext tests and groups.
- [FIX] Non-relevant tests no longer show up in summary when running a test filter.

## 3.4.3
- [FIX] Made sure that vs-code would print out all responses

## 3.4.2
- [FIX] Fixed vs-code flag not working for specific test filters

## 3.4.1
- [QoL] Implemented vs-code flag with interactive mode for easier compatibility with testing extensions.

## 3.4.0
- [ADD] Added interactive mode! You can now enter -i to continuously run tests.

## 3.3.4
- [FIX] Added a needed hook to copy over properties from one context to the next. Use the 'copyExtraParams' function to extend out this functionality to make sure parent contexts are passed to children.
- [FIX] Errors that happen during setup/action/teardown print again.
- [ADD] Errors that have a stacktrace will now output the stacktrace.

## 3.3.3
- [FIX] Fixed grabbing mapped items off of Context
- [FIX] System errors that happen during assertions (like grabbing something out of range) will now report the error like any other failed result instead of throwing an internal error.

## 3.3.2
- [FIX] On error, a test runner or group with errors will display their errors.

## 3.3.1
- [FIX] Filtering tests with tests that were skipped no longer throws error

## 3.3.0
- [ADD] You can filter files via the '-f' flag when running dart
- [FIX] Having more than 10 tests no longer misaligned the summary text box.
- [ADD] Added a -v flag to show all data, otherwise output will show a summary of all the tests found.
- [ADD] Added ability to filter tests when running dart via the '-t' flag

## 3.2.0
- [BREAKING] On groups, children are no longer a named or optional parameter
- [QoL] If a test or group does not have a contextBuilder, it will throw an error and fail the test/group instead of throwing an unhelpful error.
- [FIX] Neutral results now print out the title name along with message

## 3.1.0
- [ADD] You can now return a value on the `action` setup to assign that value to "test.actual"
- [MOD] When creating an Expect, by default the "actual" value will appear before the "expected". This is to mirror other popular testing frameworks.
- [BREAKING] Minor change, Expect.Null, Expect.IsNotNull, Expect.Type no longer needs a named parameter. Expect.isNotNull(actual: test.actual) => Expect.isNotNull(test.actual)
- [ADD] Expect.isTrue and Expect.isFalse - does about what it say on the tin. Also only takes one parameter like .null, .isNotNull, and .type.

## 3.0.0
- [BREAKING] All code refactored into a library. Pros - less imports. Cons - Breaks all current imports. Good thing this isn't public.
- [BREAKING] context.context['value'] has been moved to context['value']
- [ADD] Added Context! Er, more context. You can now call `xWithContext<Type, ContextType>` to shape the context and gets passed around the life cycle of the test.
    - The whole point behind this is to be able to extend the Context object to have the parameters you want instead of setting and calling everything on strings. (what is this, js?)
    - Also this was a pain and a half to wrestle with dart and generic types. Tacking on "WithContext" isn't entirely ideal, but it was either that or doubling the size of the library to entirely remake a separate version of dart. That didn't allow for interchanging WithContent and not for children. Just no.
- [MOD] Minor QoL -> when writing a test or group, the previous default "context" parameter is now labeled "test" this is to avoid a very confusing test.test

## 2.0.0
Features:
- Teardown step
    - You can now add a teardown function to your tests. As long as the setup successfully runs, the teardown step will try to run as well, regardless of what else may happen in the test.

- GROUPS!
    - See test folder for usage. This causes breaking changes for current tests. Existing tests can add the `Test.Single()` constructor to run individually for backwards compatibility (and for when you just want to run a simple one-off test).
    - The "Test Runner" class is a special top-level group that runs all tests and groups inside it and displays a fancy summary at the end.
    - Groups can have setup and teardown just like tests


Misc improvements:
- Setup, action, and teardown can be asynchronous. Warning that these may hold up the rest of the test suite. (Option to add a timeout and running async for better performance may be added in the future)
- Error messages will be formatted to line up with the test they failed on
- No tests found will not throw an exception, but handle it with a message

## 1.1.2
- Drop the sdk version to be a little lower for compatibility

## 1.1.1
- Loosened typings on Expect to allow for types outside of the test type

## 1.1.0
- Added Expect types isNull, isNotNull, and isType

## 1.0.0

- Initial version.
