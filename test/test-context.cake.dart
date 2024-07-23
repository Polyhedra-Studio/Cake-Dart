import 'package:cake/cake.dart';

void main() async {
  TestRunnerOf('Test Runner -  Default Context', []);
  TestRunner<Context>(
    'Test Runner - With Context',
    [],
    contextBuilder: Context.new,
  );
  TestRunner<_Extended>(
    'Test Runner - with custom context',
    [],
    contextBuilder: _Extended.new,
  );
  TestRunnerDefault('Test Runner - Parent Test Runner', [
    Group('Group Without Context', []),
    Group('Group With Context', [], contextBuilder: Context.new),
    Group<_Extended>(
      'Group with custom context',
      [],
      contextBuilder: _Extended.new,
    ),
    Group('Parent Group', [
      Group('Nested Group', []),
      Group('Nested Group with context', [], contextBuilder: Context.new),
      Group<_Extended>(
        'Nested Group with custom context',
        [],
        contextBuilder: _Extended.new,
      ),
      Test(
        'Nested test without context',
        assertions: (test) => [
          Expect.isTrue(true),
        ],
      ),
      Test.stub('Nested Test without context'),
      Test<_Extended>.stub(
        'Nested test with custom context',
        contextBuilder: _Extended.new,
      ),
    ]),
    Test.stub('Test under parent test runner'),
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
              Expect.equals(expected: test.value, actual: 'action'),
            ],
            teardown: (test) => test.value = 'teardown',
          ),
        ],
      ),
      Group<_SuperExtended>(
        'Group with context passes context to children',
        [
          Test(
            'Test inherits parent context at all steps',
            action: (test) => 'setup',
            assertions: (test) => [
              Expect<String>.isType(test.actual),
            ],
          ),
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
    contextBuilder: _Extended.new,
  );

  TestRunnerDefault(
    'Test Runner - TestOf, GroupOf',
    [
      TestOf<String>.stub('TestOf'),
      TestOf<String>.skip('TestOf', assertions: (test) => []),
      TestOf<String>(
        'Should test against a string',
        action: (test) => 'test',
        assertions: (test) =>
            [Expect.equals(actual: test.actual, expected: 'test')],
      ),
      Group(
        'Has a TestOf Child',
        [
          TestOf<bool>(
            'Should test against a bool',
            action: (test) => true,
            assertions: (test) => [Expect.isTrue(test.actual)],
          ),
        ],
      ),
      GroupOf<String>(
        'GroupOf should test against a type',
        [
          Test(
            'Should test against a string',
            action: (test) => '',
            assertions: (test) => [Expect.isTrue(test.actual?.isEmpty)],
          ),
        ],
      ),
      GroupOf.skip('Skipped GroupOf', [
        Test(
          'Should test against a string',
          action: (test) => 'cake',
          // Intentionally bad assertion
          assertions: (test) => [Expect.isTrue(test.actual?.isEmpty)],
        ),
      ]),
    ],
  );

  TestRunnerDefault(
    'Context Meta Information',
    [
      Group('Title: Group', [
        Test(
          'Title: Test',
          assertions: (test) => [
            Expect.equals(actual: test.title, expected: 'Title: Test'),
          ],
        ),
      ]),
      Test(
        'Title: Direct child test',
        assertions: (test) => [
          Expect.equals(
            actual: test.title,
            expected: 'Title: Direct child test',
          ),
        ],
      ),
      Group(
        'Contextual Type: Group',
        [
          Test(
            'Contextual Type: Test',
            assertions: (test) => [
              Expect.equals(actual: test.contextualType, expected: 'Test'),
            ],
          ),
        ],
      ),
      Test(
        'Contextual Type: Direct child test',
        assertions: (test) => [
          Expect.equals(
            actual: test.contextualType,
            expected: 'Test',
          ),
        ],
      ),
    ],
  );
}

class _Extended extends Context {
  String value = '';
}

class _SuperExtended extends _Extended {
  String superValue = '';
}
