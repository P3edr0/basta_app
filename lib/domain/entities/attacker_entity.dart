import 'dart:convert';

import 'package:flutter/services.dart';

class AttackerEntity {
  final String? image;
  final String? protectionId;
  final String? name;
  final Uint8List? imageFile;

  AttackerEntity({this.image, this.protectionId, this.name, this.imageFile});

  AttackerEntity copyWith({String? image, String? protectionId, String? name, Uint8List? imageFile}) {
    return AttackerEntity(
      image: image ?? this.image,
      protectionId: protectionId ?? this.protectionId,
      name: name ?? this.name,
      imageFile: imageFile ?? this.imageFile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'protectionId': protectionId,
      'name': name,
      'imageFile': imageFile,
    };
  }

  factory AttackerEntity.fromMap(Map<String, dynamic> map) {
    return AttackerEntity(
      image: map['image'] != null ? map['image'] as String : null,
      protectionId:
          map['protectionId'] != null ? map['protectionId'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      imageFile: map['imageFile'] != null ? map['imageFile'] as Uint8List : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttackerEntity.fromJson(String source) =>
      AttackerEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AttackerEntity(image: $image, protectionId: $protectionId, name: $name)';

  @override
  bool operator ==(covariant AttackerEntity other) {
    if (identical(this, other)) return true;

    return other.image == image &&
        other.protectionId == protectionId &&
        other.name == name;
  }
}
