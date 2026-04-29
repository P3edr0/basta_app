// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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
  AddressEntity address;
  AttackerEntity? attacker;
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
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      image: map['image'] as String,
      name: map['name'] as String,
      cpf: map['cpf'],
      phone: map['phone'] as String,
      email: map['email'] as String,
      notificationToken: map['notificationToken'],
      address: AddressEntity.fromMap(map['address'] as Map<String, dynamic>),
      attacker: AttackerEntity.fromMap(map['attacker'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
