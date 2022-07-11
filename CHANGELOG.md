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
