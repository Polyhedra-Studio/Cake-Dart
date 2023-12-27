import 'package:cake/helper/filter_settings.dart';

class CakeSettings {
  final String? fileFilter;
  final bool verbose;
  final bool isVsCode;
  final FilterSettings testFilter;
  final bool interactive;
  final bool showHelp;
  final bool forceFlutter;

  CakeSettings(List<String> args)
      : verbose = args.contains('-v') || args.contains('--verbose'),
        fileFilter = _getFromArgs(args, '-f'),
        isVsCode = args.contains('--vs-code'),
        interactive = args.contains('-i') || args.contains('--interactive'),
        showHelp = args.contains('-h') || args.contains('--help'),
        forceFlutter = args.contains('--flutter'),
        testFilter = FilterSettings(
          generalSearchTerm: _getFromArgs(args, '-t'),
          testFilterTerm: _getFromArgs(args, '--tt'),
          testSearchFor: _getFromArgs(args, '--tte'),
          groupFilterTerm: _getFromArgs(args, '--tg'),
          groupSearchFor: _getFromArgs(args, '--tge'),
          testRunnerFilterTerm: _getFromArgs(args, '--tr'),
          testRunnerSearchFor: _getFromArgs(args, '--tre'),
        );

  static String? _getFromArgs(List<String> args, String flag) {
    final int fileFilterFlagIndex = args.indexOf(flag);
    if (fileFilterFlagIndex != -1 && fileFilterFlagIndex != args.length - 1) {
      return args[fileFilterFlagIndex + 1];
    }
    return null;
  }
}
