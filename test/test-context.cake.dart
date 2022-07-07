import 'package:cake/cake.dart';

void main() async {
  TestRunner('Test Runner -  Without Context', []);
  TestRunnerWithContext<dynamic, Context>('Test Runner - With Context', [],
      contextBuilder: Context.new);
  TestRunnerWithContext<String, _Extended<String>>(
      'Test Runner - with custom context', [],
      contextBuilder: _Extended.new);
  TestRunner('Test Runner - Parent Test Runner', [
    Group('Group Without Context'),
    GroupWithContext('Group With Context', contextBuilder: Context.new),
    GroupWithContext<String, _Extended<String>>('Group with custom context',
        contextBuilder: _Extended.new),
    Group('Parent Group', children: [
      Group('Nested Group'),
      GroupWithContext('Nested Group with context',
          contextBuilder: Context.new),
      GroupWithContext<String, _Extended<String>>(
          'Nested Group with custom context',
          contextBuilder: _Extended.new),
      Test('Nested Test without context'),
      TestWithContext('Nested Test with context', contextBuilder: Context.new),
      TestWithContext<String, _Extended<String>>(
          'Nested test with custom context',
          contextBuilder: _Extended.new),
    ]),
  ]);

  TestRunnerWithContext<String, _Extended<String>>(
      'Test Runner with context passes context to children',
      [
        GroupWithContext<bool, _SuperExtended<bool>>(
            'Group with context passes context to children',
            contextBuilder: _SuperExtended.new,
            children: [
              Test(
                'Test inherits parent context at all steps',
                expected: 'blah',
                actual: 'nah',
                // setup: (test) => test.value = 'setup',
              )
            ]),
      ],
      contextBuilder: _Extended.new);
}

class _Extended<T> extends Context<T> {
  String value = '';
}

class _SuperExtended<T> extends _Extended<T> {
  String superValue = '';
}
