class GiValueHandler {
  static String smallNumberToShow(int value) {
    final content = value < 10 ? '0$value' : value.toString();
    return content;
  }

  static String onlyDigits(String content) {
    String onlyDigits = content.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits;
  }
}

extension OnlyDigits on String {
  String onlyDigits() {
    String onlyDigits = replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits;
  }
}
