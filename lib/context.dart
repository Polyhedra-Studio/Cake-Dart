part of 'cake.dart';

/// Context is how information can be passed from stage to stage.
///
/// This is passed as an argument on each stage and and is an
/// inheritable object that is passed from parent to children. By default, test
/// has an [actual] value, an [expected] value, and an additional map to pass
/// information through ad-hoc. The default Context is called by using the
/// [TestRunnerDefault] constructor.
class Context<ExpectedType> extends Object implements Map<String, dynamic> {
  final Map<String, dynamic> _context = {};
  ExpectedType? expected;
  ExpectedType? actual;

  Context.deepCopy(Context siblingContext) {
    copy(siblingContext);
  }
  Context();

  void copy(Context parentContext) {
    addAll(parentContext);
    expected = parentContext.expected;
    actual = parentContext.actual;
    copyExtraParams(parentContext);
  }

  /// Copies extra parameters from parent group to child
  /// Remember to include this if you create and set named parameters
  /// outside of using the context map.
  ///
  /// Example:
  ///
  /// ```dart
  /// class IntContext extends Context<int> {
  ///   int count = 0;
  ///   IntContext();
  ///
  ///   @override
  ///   void copyExtraParams(Context contextToCopyFrom) {
  ///     if (contextToCopyFrom is IntContext) {
  ///       count = contextToCopyFrom.count;
  ///     }
  ///   }
  /// }
  /// ```
  void copyExtraParams(Context contextToCopyFrom) {
    return;
  }

  @override
  dynamic operator [](Object? key) {
    return _context[key];
  }

  @override
  void operator []=(String key, value) {
    _context[key] = value;
  }

  @override
  void addAll(Map<String, dynamic> other) {
    _context.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) {
    _context.addEntries(newEntries);
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _context.cast<RK, RV>();
  }

  @override
  void clear() {
    _context.clear();
  }

  @override
  bool containsKey(Object? key) {
    return _context.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return _context.containsValue(value);
  }

  @override
  Iterable<MapEntry<String, dynamic>> get entries => _context.entries;

  @override
  void forEach(void Function(String key, dynamic value) action) {
    _context.forEach(action);
  }

  @override
  bool get isEmpty => _context.isEmpty;

  @override
  bool get isNotEmpty => _context.isNotEmpty;

  @override
  Iterable<String> get keys => _context.keys;

  @override
  int get length => _context.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(String key, dynamic value) convert,
  ) {
    return _context.map(convert);
  }

  @override
  dynamic putIfAbsent(String key, Function() ifAbsent) {
    return _context.putIfAbsent(key, ifAbsent);
  }

  @override
  dynamic remove(Object? key) {
    return _context.remove(key);
  }

  @override
  void removeWhere(bool Function(String key, dynamic value) test) {
    _context.removeWhere(test);
  }

  @override
  dynamic update(
    String key,
    Function(dynamic value) update, {
    Function()? ifAbsent,
  }) {
    return _context.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(Function(String key, dynamic value) update) {
    _context.updateAll(update);
  }

  @override
  Iterable get values => _context.values;
}

class ContextCreator<C extends Context> {
  final C Function() creator;
  ContextCreator(this.creator);

  C getGenericInstance() {
    return creator();
  }
}
