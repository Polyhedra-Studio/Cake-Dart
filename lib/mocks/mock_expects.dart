part of '../cake.dart';

class MockExpect<Mock extends MockBase> extends Expect<Mock> {
  Mock? _mock;
  MockExpect(Mock? mock)
      : _mock = mock,
        super(actual: mock, expected: null);

  factory MockExpect.called(Mock? mock) {
    return _MockExpectCalled(mock);
  }

  factory MockExpect.calledOnce(Mock? mock) {
    return _MockExpectCalledOnce(mock);
  }

  factory MockExpect.calledN(Mock? mock, {required int n}) {
    return _MockExpectCalledN(mock, n: n);
  }

  factory MockExpect.notCalled(Mock? mock) {
    return _MockExpectNotCalled(mock);
  }

  factory MockExpect.calledWith(
    Mock? mock, {
    List<dynamic>? args,
    Map<String, dynamic>? namedArgs,
  }) {
    return _MockExpectCalledWith(mock, args: CallArgs(args, namedArgs));
  }

  factory MockExpect.calledWithLast(
    Mock? mock, {
    List<dynamic>? args,
    Map<String, dynamic>? namedArgs,
  }) {
    return _MockExpectCalledWithLast(mock, args: CallArgs(args, namedArgs));
  }

  factory MockExpect.calledInOrder(
    Mock? mock, {
    required List<CallArgs> sequence,
    bool allowExtraCalls = false,
  }) {
    return _MockExpectCalledInOrder(
      mock,
      sequence: sequence,
      allowExtraCalls: allowExtraCalls,
    );
  }

  factory MockExpect.calledHistory(
    Mock? mock, {
    required List<CallArgs> history,
  }) {
    return _MockExpectCalledHistory(mock, history: history);
  }
}

class _MockExpectCalled<Mock extends MockBase> extends MockExpect<Mock> {
  _MockExpectCalled(super.mock);

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called failed: Mock not found.',
      );
    }
    if (super._mock!.callCount > 0) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Mock Called failed: Expected at least one call.',
      );
    }
  }
}

class _MockExpectCalledOnce<Mock extends MockBase> extends MockExpect<Mock> {
  _MockExpectCalledOnce(super.mock);

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called Once failed: Mock not found.',
      );
    }
    if (super._mock!.callCount == 1) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Mock Called Once failed: Expected one call, received ${super._mock!.callCount}.',
      );
    }
  }
}

class _MockExpectCalledN<Mock extends MockBase> extends MockExpect<Mock> {
  final int _n;
  _MockExpectCalledN(super.mock, {required int n}) : _n = n;

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called N failed: Mock not found.',
      );
    }
    if (super._mock!.callCount == _n) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Mock Called N failed: Expected $_n calls, received ${super._mock!.callCount}.',
      );
    }
  }
}

class _MockExpectNotCalled<Mock extends MockBase> extends MockExpect<Mock> {
  _MockExpectNotCalled(super.mock);

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Not Called failed: Mock not found.',
      );
    }
    if (super._mock!.callCount == 0) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Mock Not Called failed: Expected no calls, received ${super._mock!.callCount}.',
      );
    }
  }
}

class _MockExpectCalledWith<Mock extends MockBase> extends MockExpect<Mock> {
  final CallArgs _args;

  _MockExpectCalledWith(
    super.mock, {
    required CallArgs args,
  }) : _args = args;

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called With failed: Mock not found.',
      );
    }
    if (super._mock!.callCount == 0) {
      return AssertFailure(
        'Mock Called With failed: Mock was not called, expected to be called at least once with $_args.',
      );
    }
    for (final CallArgs? callArgs in super._mock!.callArgs) {
      if (callArgs == null) {
        continue;
      }
      if (callArgs == _args) {
        return AssertPass();
      }
    }

    return AssertFailure(
      'Mock Called With failed: Expected to be called with $_args, last call was ${super._mock!.callArgs.last}.',
    );
  }
}

class _MockExpectCalledWithLast<Mock extends MockBase>
    extends MockExpect<Mock> {
  final CallArgs _args;

  _MockExpectCalledWithLast(
    super.mock, {
    required CallArgs args,
  }) : _args = args;

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called With Last failed: Mock not found.',
      );
    }
    if (super._mock!.callCount == 0) {
      return AssertFailure(
        'Mock Called With Last failed: Mock was not called, expected to be called at least once with $_args.',
      );
    }
    final CallArgs? callArgs = super._mock!.callArgs.last;
    if (callArgs == null) {
      return AssertFailure(
        'Mock Called With Last failed: Mock was called with no arguments, expected to be called with $_args.',
      );
    }
    if (callArgs == _args) {
      return AssertPass();
    } else {
      return AssertFailure(
        'Mock Called With Last failed: Expected last call to be with $_args, last call was made with $callArgs.',
      );
    }
  }
}

class _MockExpectCalledHistory<Mock extends MockBase> extends MockExpect<Mock> {
  final List<CallArgs> _history;

  _MockExpectCalledHistory(
    super.mock, {
    required List<CallArgs> history,
  }) : _history = history;

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called History failed: Mock not found.',
      );
    }
    if (super._mock!.callCount != _history.length) {
      return AssertFailure(
        'Mock Called History failed: Mock was called ${super._mock!.callCount} times, expected to be called ${_history.length} times.',
      );
    }
    final List<CallArgs?> callHistory = super._mock!.callArgs;

    for (int i = 0; i < _history.length; i++) {
      if (_history[i] != callHistory[i]) {
        return AssertFailure(
          'Mock Called History failed: Expected call ${i + 1} to be ${_history[i]}, call ${i + 1} was ${callHistory[i]}.',
        );
      }
    }

    return AssertPass();
  }
}

class _MockExpectCalledInOrder<Mock extends MockBase> extends MockExpect<Mock> {
  final List<CallArgs> _sequence;
  final bool _allowExtraCalls;

  _MockExpectCalledInOrder(
    super.mock, {
    required List<CallArgs> sequence,
    bool allowExtraCalls = false,
  })  : _sequence = sequence,
        _allowExtraCalls = allowExtraCalls;

  @override
  AssertResult run() {
    if (super._mock == null) {
      return AssertFailure(
        'Mock Called In Order failed: Mock not found.',
      );
    }
    if (_sequence.isEmpty) {
      // This would always pass since no matter what since nothing is expected
      return AssertPass();
    }
    if (super._mock!.callCount < _sequence.length) {
      // Obvious failure - no need to run the rest of the logic
      return AssertFailure(
        'Mock Called In Order failed: Mock was called ${super._mock!.callCount} times, expected to be called at least ${_sequence.length} times.',
      );
    }

    if (_allowExtraCalls) {
      return _loose();
    } else {
      return _strict();
    }
  }

  AssertResult _strict() {
    final List<CallArgs?> callHistory = super._mock!.callArgs;
    final int maxIndex = callHistory.length - _sequence.length;

    for (int startIndex = 0; startIndex <= maxIndex; startIndex++) {
      bool allMatch = true;

      // Check if the sequence matches consecutively from this starting point
      for (int i = 0; i < _sequence.length; i++) {
        if (_sequence[i] != callHistory[startIndex + i]) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) {
        return AssertPass();
      }
    }

    // Ran through the entire history and could not find any matches
    return AssertFailure(
      'Mock Called In Order failed: Expected to be called in order ${_sequence.join(', ')}, but could not find any expected calls.',
    );
  }

  AssertResult _loose() {
    final List<CallArgs?> callHistory = super._mock!.callArgs;

    int historyIndex = 0;
    final List<CallArgs> foundCalls = [];
    for (int i = 0; i < _sequence.length; i++) {
      while (historyIndex < callHistory.length) {
        if (_sequence[i] == callHistory[historyIndex]) {
          // Match found
          foundCalls.add(_sequence[i]);
          if (i == _sequence.length - 1) {
            // If this is the last item to search for, pass the test
            return AssertPass();
          } else {
            // More to search on, break out of the loop and continue next in the sequence
            historyIndex++;
            break;
          }
        }

        historyIndex++;
      }
    }

    // Ran through the entire history and could not find any matches
    if (foundCalls.isEmpty) {
      return AssertFailure(
        'Mock Called In Order failed: Expected to be called in order ${_sequence.join(', ')}, but could not find any expected calls.',
      );
    }

    return AssertFailure(
      'Mock Called In Order failed: Expected to be called in order ${_sequence.join(', ')}, but could only find ${foundCalls.join(', ')} in order.',
    );
  }
}
