enum GuardianFilterType {
  addAngel,
  requests;

  bool get isRequest => this == requests;
  bool get isAddAngel => this == addAngel;
}
