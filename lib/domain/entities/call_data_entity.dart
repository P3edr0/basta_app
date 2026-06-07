// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CallDataEntity {
  final String serverUrl;
  final String roomName;
  final String token;

  CallDataEntity({
    required this.serverUrl,
    required this.roomName,
    required this.token,
  });

  CallDataEntity copyWith({
    String? serverUrl,
    String? roomName,
    String? token,
  }) {
    return CallDataEntity(
      serverUrl: serverUrl ?? this.serverUrl,
      roomName: roomName ?? this.roomName,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'serverUrl': serverUrl,
      'roomName': roomName,
      'token': token,
    };
  }

  static CallDataEntity fromMap(Map<String, dynamic> map) {
    return CallDataEntity(
      serverUrl: map['serverUrl'] as String,
      roomName: map['roomName'] as String,
      token: map["participantToken"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CallDataEntity.fromJson(String source) =>
      CallDataEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CallDataEntity(serverUrl: $serverUrl, roomName: $roomName, token: $token)';

  @override
  bool operator ==(covariant CallDataEntity other) {
    if (identical(this, other)) return true;

    return other.serverUrl == serverUrl &&
        other.roomName == roomName &&
        other.token == token;
  }

  @override
  int get hashCode => serverUrl.hashCode ^ roomName.hashCode ^ token.hashCode;
}
