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
