import 'package:cake/cake.dart';

void main() async {
  TestRunner('Test Runner -  Without Context', []);
  TestRunnerWithContext<Context>('Test Runner - With Context', [],
      contextBuilder: Context.new);
  TestRunnerWithContext<_Extended<String>>(
      'Test Runner - with custom context', [],
      contextBuilder: _Extended.new);
  TestRunner('Test Runner - Parent Test Runner', [
    Group('Group Without Context', []),
    GroupWithContext('Group With Context', [], contextBuilder: Context.new),
    GroupWithContext<_Extended<String>>('Group with custom context', [],
        contextBuilder: _Extended.new),
    Group('Parent Group', [
      Group('Nested Group', []),
      GroupWithContext('Nested Group with context', [],
          contextBuilder: Context.new),
      GroupWithContext<_Extended<String>>(
          'Nested Group with custom context', [],
          contextBuilder: _Extended.new),
      Test('Nested Test without context'),
      TestWithContext('Nested Test with context', contextBuilder: Context.new),
      TestWithContext<String, _Extended<String>>(
          'Nested test with custom context',
          contextBuilder: _Extended.new),
    ]),
  ]);

  TestRunnerWithContext<_Extended<String>>(
      'Test Runner with context passes context to children',
      [
        GroupWithContext(
          'Group with same context passes context to children',
          [
            TestWithContext(
              'Child has parent context',
              expected: 'yes',
              actual: 'yes',
              setup: (test) {
                test.value = 'setup';
              },
              action: (test) {
                test.value = 'action';
              },
              assertions: (test) => [
                Expect.equals(expected: test.expected, actual: test.actual),
                Expect<String>.isType(test.value),
                Expect.equals(expected: test.value, actual: 'action')
              ],
              teardown: (test) => test.value = 'teardown',
            ),
          ],
        ),
        GroupWithContext<_SuperExtended<String>>(
          'Group with context passes context to children',
          [
            TestWithContext<String, _SuperExtended<String>>(
              'Test inherits parent context at all steps',
              expected: 'yes',
              actual: 'yes',
              setup: (test) => test.value = 'setup',
            ),
            TestWithContext('Test automatically inherits parent context',
                expected: 'yes',
                actual: 'yes',
                setup: (test) => test.value = 'setup'),
          ],
          contextBuilder: _SuperExtended.new,
        ),
      ],
      contextBuilder: _Extended.new);

  // TestRunner('This should fail', [
  //   GroupWithContext('Group with forgotten context', [
  //     TestWithContext('This should fail without a declared context anywhere'),
  //   ]),
  // ]);
}

class _Extended<T> extends Context<T> {
  String value = '';
}

class _SuperExtended<T> extends _Extended<T> {
  String superValue = '';
}
