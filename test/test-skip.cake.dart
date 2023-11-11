import 'package:cake/cake.dart';

void main() async {
  TestRunnerDefault.skip('Test Runner Default can skip empty', []);

  TestRunnerDefault.skip('Test Runner Default can skip', [
    Group(
      'This group should be skipped',
      [
        Test(
          'This test should be skipped',
          assertions: (test) => [
            Expect.isTrue(false),
          ],
        ),
      ],
    ),
    Test(
      'This test should be skipped',
      assertions: (test) => [
        Expect.isTrue(false),
      ],
    ),
  ]);

  TestRunner<Context>.skip(
    'Test Runner can skip - empty',
    [],
    contextBuilder: Context.new,
  );

  TestRunner<Context>.skip(
    'Test Runner can skip',
    [
      Group(
        'This group should be skipped',
        [
          Test(
            'This test should be skipped',
            assertions: (test) => [
              Expect.isTrue(false),
            ],
          ),
        ],
      ),
      Test(
        'This test should be skipped',
        assertions: (test) => [
          Expect.isTrue(false),
        ],
      ),
    ],
    contextBuilder: Context.new,
  );

  TestRunnerDefault('Test Runner - Children marked skipped should skip', [
    Group.skip('This group should be skipped', [
      Test(
        'This test should be skipped',
        assertions: (test) => [
          Expect.isTrue(false),
        ],
      ),
    ]),
    Group('This group should not be skipped', [
      Test(
        'This test should not be skipped',
        assertions: (test) => [
          Expect.isTrue(true),
        ],
      ),
    ]),
    Group.skip('This GroupDefault should be skipped', [
      Test(
        'This test should be skipped',
        assertions: (test) => [
          Expect.isTrue(false),
        ],
      ),
    ]),
    GroupOf('This GroupDefault should not be skipped', [
      Test(
        'This test should not be skipped',
        assertions: (test) => [
          Expect.isTrue(true),
        ],
      ),
    ]),
    Test.skip(
      'This test should be skipped',
      assertions: (test) => [Expect.isTrue(false)],
    ),
    Test(
      'This test should not be skipped',
      assertions: (test) => [
        Expect.isTrue(true),
      ],
    ),
  ]);
}
