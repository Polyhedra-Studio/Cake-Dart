# TODO
    - Runner
        [X] Running in a directory without any unit tests should show a _handled_ error in ~~red~~ gray. Right now it is treated as an unhandled error.
        [X] Make setup and all other functions optionally async
        [X] When all tests ~~pass or one tests fail~~ finish, post a summary message
        [X] Add Four spaces to indent error messages
        [ ] Add a result for "stubbed" tests
        [X] Add groups for tests
            [X] Groups should indent children tests
            [X] Groups should have a title and output name
            [X] Groups should have a setup and teardown step
        [X] Add teardown for individual tests
        [ ] Add skip constructor
        [X] Allow for extending the context item
        [ ] Show the test runner summary for every time _cake_ is run, not every time a test runner finishes.

    - ExpectTypes
        - More?
    
    - Bugs
        [X] Expect<T>.isType should ignore any parent typing for test.actual (as in, if actual is meant to be class Foo, and you want to check if it's class Bar, it should be valid to check Expect<Bar>(test.actual). This is a valid case in inherited classes that dart would normally throw an error for)