import 'dart:convert';

import '../../utils/enums/guardian_status.dart';

class GuardianEntity {
  final String? id;
  final String? image;
  final String? addressResume;
  final String? orderId;
  final String name;
  final GuardianStatus? status;


  GuardianEntity({
    this.id,
    this.image,
    this.addressResume,
    required this.name,
    this.status,
    this.orderId,
  
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'image': image, 'name': name};
  }

  factory GuardianEntity.fromMap(Map<String, dynamic> map) {
    final addressResume =
        "${map['address']['city']},${map['address']['state']}";
    return GuardianEntity(
      id: map['id'],
      image: map['image'],
      name: map['name'] as String,
     
      addressResume: addressResume,
      status: GuardianStatus.none,
    );
  }

  String toJson() => json.encode(toMap());

  factory GuardianEntity.fromJson(String source) =>
      GuardianEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  GuardianEntity copyWith({
    String? id,
    String? userId,
    String? image,
    String? addressResume,
    String? name,
     List<String>? myGuardians,   
       List<String>? protect,
    GuardianStatus? status,
    String? orderId,
  }) {
    return GuardianEntity(
      id: id ?? this.id,
      image: image ?? this.image,
      addressResume: addressResume ?? this.addressResume,
      name: name ?? this.name,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
     
    );
  }
}
