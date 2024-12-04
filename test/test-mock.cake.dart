import 'package:cake/cake.dart';

void main() async {
  TestRunnerDefault('Mocks', [
    Group('Mocking Functions', [
      Test(
        'Can create a mockable function',
        action: (test) => MockableFunction(),
        assertions: (test) => [
          Expect.isTrue(true),
        ],
      ),
      Test(
        'Mocks can be called and will return their value',
        action: (test) {
          final MockableFunction mock = MockableFunction(true);
          return mock.call([1, 2, 3], {'a': 'b'});
        },
        assertions: (test) => [
          Expect.isTrue(test.actual),
        ],
      ),
      Test(
        'Mocks can be called multiple times',
        action: (test) {
          final MockableFunction mock = MockableFunction(true);
          mock.call([1, 2, 3], {'a': 'b'});
          mock.call([1, 2, 3], {'a': 'b'});
          return mock;
        },
        assertions: (test) => [
          MockExpect.calledN(test.actual, n: 2),
          MockExpect.calledWith(
            test.actual,
            args: [1, 2, 3],
            namedArgs: {'a': 'b'},
          ),
        ],
      ),
      Test(
        'Mocks can be reset',
        action: (test) {
          final MockableFunction mock = MockableFunction(true);
          mock.call([1, 2, 3], {'a': 'b'});
          mock.reset();
          return mock;
        },
        assertions: (test) => [
          MockExpect.notCalled(test.actual),
        ],
      ),
    ]),
    Group(
      'Mock Expects',
      [
        Test(
          'MockExpect.called passes if called at least once',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            return mock;
          },
          assertions: (test) => [
            MockExpect.called(test.actual),
          ],
        ),
        Test(
          'MockExpect.calledOnce passes if called once',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            return mock;
          },
          assertions: (test) => [
            MockExpect.calledOnce(test.actual),
          ],
        ),
        Test(
          'MockExpect.calledOnce does not pass if called more than once',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            mock.call();
            return mock;
          },
          assertions: (test) {
            final AssertResult result =
                MockExpect.calledOnce(test.actual as MockableFunction).run();
            return [
              Expect<AssertFailure>.isType(result),
            ];
          },
        ),
        Test(
          'MockExpect.calledN passes if called N times',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            mock.call();
            return mock;
          },
          assertions: (test) => [
            MockExpect.calledN(test.actual, n: 2),
          ],
        ),
        Test(
          'MockExpect.calledN does not pass if called a different number of times',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            return mock;
          },
          assertions: (test) {
            final AssertResult result =
                MockExpect.calledN(test.actual as MockableFunction, n: 2).run();
            return [
              Expect<AssertFailure>.isType(result),
            ];
          },
        ),
        Test(
          'MockExpect.notCalled passes if not called',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            return mock;
          },
          assertions: (test) => [MockExpect.notCalled(test.actual)],
        ),
        Test(
          'MockExpect.notCalled does not pass if called',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            return mock;
          },
          assertions: (test) {
            final AssertResult result =
                MockExpect.notCalled(test.actual as MockableFunction).run();
            return [
              Expect<AssertFailure>.isType(result),
            ];
          },
        ),
        Test(
          'MockExpect.calledWith passes if called with args',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call([1, 2, 3], {'a': 'b'});
            return mock;
          },
          assertions: (test) => [
            MockExpect.calledWith(
              test.actual,
              args: [1, 2, 3],
              namedArgs: {'a': 'b'},
            ),
          ],
        ),
        Test(
          'MockExpect.calledWithLast passes if called with args last',
          action: (test) {
            final MockableFunction mock = MockableFunction();
            mock.call();
            mock.call([1, 2, 3], {'a': 'b'});
            return mock;
          },
          assertions: (test) => [
            MockExpect.calledWithLast(
              test.actual,
              args: [1, 2, 3],
              namedArgs: {'a': 'b'},
            ),
          ],
        ),
        Group('MockExpect.calledInOrder', [
          Test(
            'Should pass if sequence is empty',
            action: (test) {
              final MockableFunction mock = MockableFunction();
              mock.call(['arg1']);
              mock.call(['arg2']);
              mock.call(['arg3']);
              return mock;
            },
            assertions: (test) => [
              MockExpect.calledInOrder(test.actual, sequence: []),
            ],
          ),
          Test(
            'Should fail if sequence is bigger than call history',
            action: (test) {
              final MockableFunction mock = MockableFunction();
              mock.call(['arg1']);
              return mock;
            },
            assertions: (test) {
              final AssertResult result = MockExpect.calledInOrder(
                test.actual as MockableFunction,
                sequence: [
                  CallArgs(['arg1']),
                  CallArgs(['arg2']),
                  CallArgs(['arg3']),
                ],
              ).run();

              return [
                Expect<AssertFailure>.isType(result),
              ];
            },
          ),
          Group('Strict mode', [
            Test(
              'Strict mode passes if called in order',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg2']);
                mock.call(['arg3']);
                return mock;
              },
              assertions: (test) => [
                MockExpect.calledInOrder(
                  test.actual,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                ),
              ],
            ),
            Test(
              'Strict mode does not pass if extra calls are made between the sequence',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg2']);
                mock.call(['extra should make this fail']);
                mock.call(['arg3']);
                return mock;
              },
              assertions: (test) {
                final AssertResult result = MockExpect.calledInOrder(
                  test.actual as MockableFunction,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                ).run();

                return [
                  Expect<AssertFailure>.isType(result),
                ];
              },
            ),
            Test(
              'calledInOrder should fail if not called in order',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg3']);
                mock.call(['arg2']);
                return mock;
              },
              assertions: (test) {
                final AssertResult result = MockExpect.calledInOrder(
                  test.actual as MockableFunction,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                ).run();

                return [
                  Expect<AssertFailure>.isType(result),
                ];
              },
            ),
          ]),
          Group('Allow extra calls', [
            Test(
              'Allowing calls passes if called in order',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg2']);
                mock.call(['arg3']);
                return mock;
              },
              assertions: (test) => [
                MockExpect.calledInOrder(
                  test.actual,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                  allowExtraCalls: true,
                ),
              ],
            ),
            Test(
              'Allowing calls should pass if extra calls are made between the sequence',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg2']);
                mock.call(['extra should not make this fail']);
                mock.call(['arg3']);
                return mock;
              },
              assertions: (test) => [
                MockExpect.calledInOrder(
                  test.actual as MockableFunction,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                  allowExtraCalls: true,
                ),
              ],
            ),
            Test(
              'calledInOrder should fail if not called in order - allow extra calls',
              action: (test) {
                final MockableFunction mock = MockableFunction();
                mock.call(['arg1']);
                mock.call(['arg3']);
                mock.call(['arg2']);
                return mock;
              },
              assertions: (test) {
                final AssertResult result = MockExpect.calledInOrder(
                  test.actual as MockableFunction,
                  sequence: [
                    CallArgs(['arg1']),
                    CallArgs(['arg2']),
                    CallArgs(['arg3']),
                  ],
                  allowExtraCalls: true,
                ).run();

                return [
                  Expect<AssertFailure>.isType(result),
                ];
              },
            ),
          ]),
        ]),
      ],
    ),
  ]);
}
