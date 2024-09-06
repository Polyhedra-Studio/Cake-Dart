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
