enum AngelFilterType {
  myGuardians,
  emergencies;

  bool get isMyGuardians => this == AngelFilterType.myGuardians;
  bool get isEmergencies => this == AngelFilterType.emergencies;
}
