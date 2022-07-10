class CakeSettings {
  final String? fileFilter;
  final bool verbose;
  final String? testFilter;
  final bool isVsCode;

  CakeSettings(List<String> args)
      : verbose = args.contains('-v') || args.contains('--verbose'),
        fileFilter = _getFromArgs(args, '-f'),
        testFilter = _getFromArgs(args, '-t'),
        isVsCode = args.contains('--vs-code');

  static String? _getFromArgs(List<String> args, String flag) {
    int fileFilterFlagIndex = args.indexOf('-f');
    if (fileFilterFlagIndex != -1 && fileFilterFlagIndex != args.length - 1) {
      return args[fileFilterFlagIndex + 1];
    }
    return null;
  }
}
