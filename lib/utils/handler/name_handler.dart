class NameHandler {
  static String firstName(String fullName) {
    final firstName = fullName.split(' ').first;
    return firstName;
  }

  static String surname(String fullName) {
    final names = fullName.split(' ');
    if (names.length < 2) {
      return fullName;
    }
    final surname = '${names.first} ${names[1]}';
    return surname;
  }

  static bool isFullName(String content) {
    final contents = content.split(' ');
    return contents.length > 1;
  }
}
