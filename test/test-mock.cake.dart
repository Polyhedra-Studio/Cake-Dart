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
          assertions: (test) => [
            MockExpect.calledOnce(test.actual),
          ],
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
          assertions: (test) => [
            MockExpect.calledN(test.actual, n: 2),
          ],
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
          assertions: (test) => [MockExpect.notCalled(test.actual)],
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
      ],
    ),
  ]);
}
