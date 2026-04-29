class TneRegex {
  static final RegExp onlyNumbers = RegExp('^[0-9]+\$');
  static final RegExp numbersAndLetters = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$');
}
