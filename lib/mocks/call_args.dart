part of '../cake.dart';

class CallArgs {
  final List<dynamic>? args;
  final Map<String, dynamic>? namedArgs;
  CallArgs([this.args, this.namedArgs]);

  @override
  String toString() {
    return '(Args: $args, Named Args: $namedArgs)';
  }

  @override
  @override
  bool operator ==(Object other) =>
      other is CallArgs &&
      _listEquals(args, other.args) &&
      _mapEquals(namedArgs, other.namedArgs);

  bool _listEquals(List<dynamic>? a, List<dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }

    return true;
  }

  @override
  int get hashCode => args.hashCode ^ namedArgs.hashCode;
}
