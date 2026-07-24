import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gina/domain/entities/address_entity.dart';
import 'package:gina/domain/entities/attacker_entity.dart';

class UserEntity {
  String? id;
  String? image;
  String name;
  String? cpf;
  String phone;
  String email;
  String? notificationToken;
  Uint8List? imageFile;
  AddressEntity address;
  AttackerEntity? attacker;
  bool active;
  int? scheduleToDelete;
  final List<String>? myGuardians;
  final List<String>? protect;
  UserEntity({
    this.id,
    this.image,
    required this.name,
    this.cpf,
    required this.phone,
    required this.email,
    required this.address,
    this.attacker,
    this.notificationToken,
    this.myGuardians,
    this.protect,
    this.imageFile,
    this.scheduleToDelete,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'email': email,
      'notificationToken': notificationToken,
      'address': address.toMap(),
      'attacker': attacker?.toMap(),
      'myGuardians': myGuardians,
      'protect': protect,
      'imageFile': imageFile,
      'active': active,
      'scheduleToDelete': scheduleToDelete,
    };
  }

  UserEntity copyWith({
    String? id,
    String? image,
    String? name,
    String? cpf,
    String? phone,
    String? email,
    String? notificationToken,
    AddressEntity? address,
    AttackerEntity? attacker,
    List<String>? myGuardians,
    int? scheduleToDelete,
    List<String>? protect,
    Uint8List? imageFile,
  }) {
    return UserEntity(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notificationToken: notificationToken ?? this.notificationToken,
      address: address ?? this.address,
      attacker: attacker ?? this.attacker,
      myGuardians: myGuardians ?? this.myGuardians,
      protect: protect ?? this.protect,
      imageFile: imageFile ?? this.imageFile,
      scheduleToDelete: scheduleToDelete ?? this.scheduleToDelete,
    );
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    List<String>? myGuardians;
    List<String>? protect;
    bool hasAttacker = true;
    if (map['myGuardians'] != null) {
      myGuardians = List<String>.from(map['myGuardians'] as List<dynamic>);
    }
    if (map['protected'] != null) {
      protect = List<String>.from(map['protected'] as List<dynamic>);
    }
    if (map['attacker'] == null) {
      hasAttacker = false;
    }
    return UserEntity(
      id: map['id'],
      image: map['image'] as String,
      name: map['name'] as String,
      cpf: map['cpf'],
      active: map['active'] ?? true,
      phone: map['phone'] as String,
      email: map['email'] as String,
      scheduleToDelete: map['scheduleToDelete'],
      notificationToken: map['notificationToken'],
      address: AddressEntity.fromMap(map['address'] as Map<String, dynamic>),
      attacker:
          hasAttacker
              ? AttackerEntity.fromMap(map['attacker'] as Map<String, dynamic>)
              : null,
      myGuardians: myGuardians,
      protect: protect,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
