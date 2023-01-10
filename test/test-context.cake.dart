import 'package:cake/cake.dart';

void main() async {
  TestRunnerDefault('Test Runner -  Default Context', []);
  TestRunner<Context>('Test Runner - With Context', [],
      contextBuilder: Context.new);
  TestRunner<_Extended>('Test Runner - with custom context', [],
      contextBuilder: _Extended.new);
  TestRunnerDefault('Test Runner - Parent Test Runner', [
    GroupDefault('Group Without Context', []),
    GroupDefault('Group With Context', [], contextBuilder: Context.new),
    Group<_Extended>('Group with custom context', [],
        contextBuilder: _Extended.new),
    GroupDefault('Parent Group', [
      Group('Nested Group', []),
      Group('Nested Group with context', [], contextBuilder: Context.new),
      Group<_Extended>('Nested Group with custom context', [],
          contextBuilder: _Extended.new),
      Test('Nested test without context',
          assertions: (test) => [
                Expect.isTrue(true),
              ]),
      Test.stub('Nested Test without context'),
      Test<String, _Extended>.stub('Nested test with custom context',
          contextBuilder: _Extended.new),
    ]),
    Test.stub('Test under parent test runner')
  ]);

  TestRunner<_Extended>(
      'Test Runner with context passes context to children',
      [
        Group(
          'Group with same context passes context to children',
          [
            Test(
              'Child has parent context',
              setup: (test) {
                test.value = 'setup';
              },
              action: (test) {
                test.value = 'action';
              },
              assertions: (test) => [
                Expect<String>.isType(test.value),
                Expect.equals(expected: test.value, actual: 'action')
              ],
              teardown: (test) => test.value = 'teardown',
            ),
          ],
        ),
        Group<_SuperExtended>(
          'Group with context passes context to children',
          [
            Test('Test inherits parent context at all steps',
                action: (test) => 'setup',
                assertions: (test) => [
                      Expect<String>.isType(test.actual),
                    ]),
            Test(
              'Test automatically inherits parent context',
              action: (test) => test.superValue = 'setup',
              assertions: (test) => [
                Expect<String>.isType(test.actual),
              ],
            ),
          ],
          contextBuilder: _SuperExtended.new,
        ),
      ],
      contextBuilder: _Extended.new);
}

class _Extended extends Context {
  String value = '';
}

class _SuperExtended extends _Extended {
  String superValue = '';
}
