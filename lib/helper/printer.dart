class Printer {
  static void pass(String message) {
    print('\x1B[32m$message\x1B[0m');
  }

  static void fail(String message) {
    print('\x1B[31m$message\x1B[0m');
  }

  static void neutral(String message) {
    print('\x1B[90m$message\x1B[0m');
  }
}
