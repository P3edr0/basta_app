enum EmergencyStatus {
  closed,
  active,
  closedNow;

  bool get isClosed => this == closed;
  bool get isActive => this == active;
  bool get isClosedNow => this == closedNow;
}

/*
translate(String content) {
  if (content == GuardianStatus.closed.name) {
    return GuardianStatus.closed;
  }
  if (content == GuardianStatus.refused.name) {
    return GuardianStatus.refused;
  }
  if (content == GuardianStatus.none.name) {
    return GuardianStatus.none;
  }
  if (content == GuardianStatus.invited.name) {
    return GuardianStatus.invited;
  }

  return GuardianStatus.waiting;
}*/
