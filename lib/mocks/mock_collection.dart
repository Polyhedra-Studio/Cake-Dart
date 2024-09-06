part of '../cake.dart';

class MockCollection<T extends MockBase> extends Object
    implements Map<String, T> {
  final Map<String, T> _mocks = {};

  void pause() {
    for (var mock in _mocks.values) {
      mock.pause();
    }
  }

  void resume() {
    for (var mock in _mocks.values) {
      mock.resume();
    }
  }

  void reset() {
    for (var mock in _mocks.values) {
      mock.reset();
    }
  }

  // --- Map overrides

  @override
  T? operator [](Object? key) {
    return _mocks[key];
  }

  @override
  void operator []=(String key, T value) {
    _mocks[key] = value;
  }

  @override
  void addAll(Map<String, T> other) {
    _mocks.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<String, T>> newEntries) {
    _mocks.addEntries(newEntries);
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _mocks.cast<RK, RV>();
  }

  @override
  void clear() {
    _mocks.clear();
  }

  @override
  bool containsKey(Object? key) {
    return _mocks.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return _mocks.containsValue(value);
  }

  @override
  Iterable<MapEntry<String, T>> get entries => _mocks.entries;

  @override
  void forEach(void Function(String key, T value) action) {
    _mocks.forEach(action);
  }

  @override
  bool get isEmpty => _mocks.isEmpty;

  @override
  bool get isNotEmpty => _mocks.isNotEmpty;

  @override
  Iterable<String> get keys => _mocks.keys;

  @override
  int get length => _mocks.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(String key, T value) convert,
  ) {
    return _mocks.map<K2, V2>(convert);
  }

  @override
  T putIfAbsent(
    String key,
    T Function() ifAbsent,
  ) {
    return _mocks.putIfAbsent(key, ifAbsent);
  }

  @override
  T? remove(Object? key) {
    return _mocks.remove(key);
  }

  @override
  void removeWhere(bool Function(String key, T value) test) {
    _mocks.removeWhere(test);
  }

  @override
  T update(
    String key,
    T Function(T value) update, {
    T Function()? ifAbsent,
  }) {
    return _mocks.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(
    T Function(String key, T value) update,
  ) {
    _mocks.updateAll(update);
  }

  @override
  Iterable<T> get values => _mocks.values;
}
