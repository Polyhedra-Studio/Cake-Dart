/// Stores test filters set via the command line
///
/// Used mostly internally. See [README.md#flags] for more information
class FilterSettings {
  final String? generalSearchTerm;
  final String? testFilterTerm;
  final String? testSearchFor;
  final String? groupFilterTerm;
  final String? groupSearchFor;
  final String? testRunnerFilterTerm;
  final String? testRunnerSearchFor;

  FilterSettings({
    required this.generalSearchTerm,
    required this.testFilterTerm,
    required this.testSearchFor,
    required this.groupFilterTerm,
    required this.groupSearchFor,
    required this.testRunnerFilterTerm,
    required this.testRunnerSearchFor,
  });

  FilterSettings.fromEnvironment()
      : generalSearchTerm =
            const String.fromEnvironment(_FilterSettingProps.generalSearchTerm),
        testFilterTerm =
            const String.fromEnvironment(_FilterSettingProps.testFilterTerm),
        testSearchFor =
            const String.fromEnvironment(_FilterSettingProps.testSearchFor),
        groupFilterTerm =
            const String.fromEnvironment(_FilterSettingProps.groupFilterTerm),
        groupSearchFor =
            const String.fromEnvironment(_FilterSettingProps.groupSearchFor),
        testRunnerFilterTerm = const String.fromEnvironment(
          _FilterSettingProps.testRunnerFilterTerm,
        ),
        testRunnerSearchFor = const String.fromEnvironment(
          _FilterSettingProps.testRunnerSearchFor,
        );

  bool get isNotEmpty {
    return hasGeneralSearchTerm ||
        hasTestFilterTerm ||
        hasTestSearchFor ||
        hasGroupFilterTerm ||
        hasGroupSearchFor ||
        hasTestRunnerFilterTerm ||
        hasTestRunnerSearchFor;
  }

  bool get hasGeneralSearchTerm {
    return (generalSearchTerm != null && generalSearchTerm!.isNotEmpty);
  }

  bool get hasTestFilterTerm {
    return (testFilterTerm != null && testFilterTerm!.isNotEmpty);
  }

  bool get hasTestSearchFor {
    return (testSearchFor != null && testSearchFor!.isNotEmpty);
  }

  bool get hasGroupFilterTerm {
    return (groupFilterTerm != null && groupFilterTerm!.isNotEmpty);
  }

  bool get hasGroupSearchFor {
    return (groupSearchFor != null && groupSearchFor!.isNotEmpty);
  }

  bool get hasTestRunnerFilterTerm {
    return (testRunnerFilterTerm != null && testRunnerFilterTerm!.isNotEmpty);
  }

  bool get hasTestRunnerSearchFor {
    return (testRunnerSearchFor != null && testRunnerSearchFor!.isNotEmpty);
  }

  List<String> toProperties({required bool isFlutter}) {
    final List<String> props = [];
    final String Function(String, String) buildFn =
        isFlutter ? _buildDartDefine : _buildDefine;
    if (hasGeneralSearchTerm) {
      props.add(
        buildFn(
          _FilterSettingProps.generalSearchTerm,
          generalSearchTerm!,
        ),
      );
    }
    if (hasTestFilterTerm) {
      props.add(
        buildFn(_FilterSettingProps.testFilterTerm, testFilterTerm!),
      );
    }
    if (hasTestSearchFor) {
      props.add(buildFn(_FilterSettingProps.testSearchFor, testSearchFor!));
    }
    if (hasGroupFilterTerm) {
      props.add(
        buildFn(_FilterSettingProps.groupFilterTerm, groupFilterTerm!),
      );
    }
    if (hasGroupSearchFor) {
      props.add(
        buildFn(_FilterSettingProps.groupSearchFor, groupSearchFor!),
      );
    }
    if (hasTestFilterTerm) {
      props.add(
        buildFn(_FilterSettingProps.testFilterTerm, testFilterTerm!),
      );
    }
    if (hasTestRunnerSearchFor) {
      props.add(
        buildFn(
          _FilterSettingProps.testRunnerSearchFor,
          testRunnerSearchFor!,
        ),
      );
    }
    return props;
  }

  String _buildDefine(String key, String value) => '--define=$key=$value';
  String _buildDartDefine(String key, String value) =>
      '--dart-define=$key=$value';
}

class _FilterSettingProps {
  static const String generalSearchTerm = 'generalSearchTerm';
  static const String testFilterTerm = 'testFilterTerm';
  static const String testSearchFor = 'testSearchFor';
  static const String groupFilterTerm = 'groupFilterTerm';
  static const String groupSearchFor = 'groupSearchFor';
  static const String testRunnerFilterTerm = 'testRunnerFilterTerm';
  static const String testRunnerSearchFor = 'testRunnerSearchFor';
}
