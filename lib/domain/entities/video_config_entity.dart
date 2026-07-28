import 'dart:convert';

class VideoConfigEntity {
  final String? id;
  final String? participantToken;
  final String? serverUrl;
  final String? roomName;
  VideoConfigEntity({
    this.participantToken,
    this.serverUrl,
    this.roomName,
    this.id,
  });

  VideoConfigEntity copyWith({
    String? id,
    String? participantToken,
    String? serverUrl,
    String? roomName,
  }) {
    return VideoConfigEntity(
      id: id ?? this.id,
      participantToken: participantToken ?? this.participantToken,
      serverUrl: serverUrl ?? this.serverUrl,
      roomName: roomName ?? this.roomName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'participantToken': participantToken,
      'serverUrl': serverUrl,
      'roomName': roomName,
    };
  }

  factory VideoConfigEntity.fromMap(Map<String, dynamic> map) {
    return VideoConfigEntity(
      participantToken:
          map['participantToken'] != null
              ? map['participantToken'] as String
              : null,
      id: map['id'] != null ? map['id'] as String : null,
      serverUrl: map['serverUrl'] != null ? map['serverUrl'] as String : null,
      roomName: map['roomName'] != null ? map['roomName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoConfigEntity.fromJson(String source) =>
      VideoConfigEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'GuardianEntity(participantToken: $participantToken, serverUrl: $serverUrl, roomName: $roomName)';
}
