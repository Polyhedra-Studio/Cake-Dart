import 'package:cake/cake.dart';

void main() async {
  TestRunner<TimerContext>(
    'Async Tests',
    [
      Group(
        'Can handle an async context builder',
        [
          Test(
            'Should pass if this can wait properly',
            assertions: (test) => [
              Expect.isTrue(test.pass),
            ],
            contextBuilder: () async {
              await Future.delayed(const Duration(seconds: 1));
              return TimerContext();
            },
          ),
        ],
        contextBuilder: () async {
          await Future.delayed(const Duration(seconds: 1));
          return TimerContext();
        },
      ),
    ],
    contextBuilder: () async {
      await Future.delayed(const Duration(seconds: 1));
      return TimerContext();
    },
  );

  TestRunner<TimerContext>(
    'Testing Async Cake Stages',
    [
      Group(
        'Setup should wait until finished',
        [
          Test(
            'Time should have ran',
            assertions: (test) => [
              Expect.equals(actual: test.timerCount, expected: 1),
            ],
          ),
        ],
        setup: (test) async {
          // Wait for 1 second
          await Future.delayed(const Duration(seconds: 1));
          test.timerCount = 1;
        },
      ),
    ],
    contextBuilder: TimerContext.new,
  );
}

class TimerContext extends Context<int> {
  int timerCount = 0;
  bool pass = true;
  TimerContext();

  @override
  void copyExtraParams(Context siblingContext) {
    if (siblingContext is TimerContext) {
      timerCount = siblingContext.timerCount;
      pass = siblingContext.pass;
    }
  }
}
