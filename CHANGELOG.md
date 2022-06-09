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
