class GuardianOrderEntity {
  String? id;
  String applicantId;
  String receiverId;
  bool? answer;
  DateTime sendAt;

  GuardianOrderEntity({
    this.id,
    required this.applicantId,
    required this.receiverId,
    this.answer,
    required this.sendAt,
  });

  GuardianOrderEntity copyWith({
    String? id,
    String? applicantId,
    String? receiverId,
    bool? answer,
    DateTime? sendAt,
  }) {
    return GuardianOrderEntity(
      id: id ?? this.id,
      applicantId: applicantId ?? this.applicantId,
      receiverId: receiverId ?? this.receiverId,
      answer: answer ?? this.answer,
      sendAt: sendAt ?? this.sendAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'applicantId': applicantId,
      'receiverId': receiverId,
      'answer': answer,
      'sendAt': sendAt.millisecondsSinceEpoch,
    };
  }

  factory GuardianOrderEntity.fromMap(Map<String, dynamic> map) {
    return GuardianOrderEntity(
      id: map['id'],
      applicantId: map['applicantId'] as String,
      receiverId: map['receiverId'] as String,
      answer: map['answer'],
      sendAt: DateTime.fromMillisecondsSinceEpoch(map['sendAt'] as int),
    );
  }

  @override
  String toString() {
    return 'GuardianOrderEntity(id: $id, applicantId: $applicantId, receiverId: $receiverId, answer: $answer, sendAt: $sendAt)';
  }
}
