enum GuardianStatus {
  none,
  accepted,
  refused,
  invited,
  waiting;

  bool get isAccept => this == accepted;
  bool get isWaiting => this == waiting;
  bool get isRefused => this == refused;
  bool get isInvited => this == invited;
  bool get isNone => this == none;
}

translate(String content) {
  if (content == GuardianStatus.accepted.name) {
    return GuardianStatus.accepted;
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
}
