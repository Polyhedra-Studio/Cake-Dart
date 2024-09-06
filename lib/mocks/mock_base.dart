part of '../cake.dart';

/// MockBase behaves as a template for all Mock implementations. The default
/// implementation in Cake is [MockableFunction] and [MockableFunctionOf]. But
/// you can create your own Mocks by extending this class.
///
/// For examples on how to use this with a mock, see [MockableFunction].
abstract class MockBase<T> {
  T get value;
  set value(T value);
  int callCount = 0;
  List<CallArgs?> callArgs = [];

  bool get called => callCount > 0;

  void reset() {}
  void pause();
  void resume();
  T call();
}
