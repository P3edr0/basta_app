// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PoliceStationEntity {
  final String name;
  final String address;
  final String? phone;
  final bool open;
  final bool operational;
  final double distance;
  final String? photo;
  final Coordinates coordinates;
  PoliceStationEntity({
    required this.name,
    required this.address,
    this.phone,
    required this.operational,
    required this.open,
    this.photo,
    required this.coordinates,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'address': address,
      'phone': phone,
      'open': open,
      'photo': photo,
      'distance': distance,
    };
  }

  factory PoliceStationEntity.fromMap(Map<String, dynamic> map) {
    final photo = map['photos']?[0]['photo_reference'];
    final coordinates = map['geometry']['location'];
    final open = map['opening_hours']?['open_now'] ?? true;
    final operational = map['business_status'] == 'OPERATIONAL';
    return PoliceStationEntity(
      name: map['name'] as String,
      address: map['vicinity'] as String,
      distance: map['distance'] as double,
      phone: map['international_phone_number'],
      open: open,
      photo: photo,
      operational: operational,
      coordinates: Coordinates.fromMap(coordinates),
    );
  }

  String toJson() => json.encode(toMap());

  factory PoliceStationEntity.fromJson(String source) =>
      PoliceStationEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'latitude': latitude, 'longitude': longitude};
  }

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map['lat'] as double,
      longitude: map['lng'] as double,
    );
  }

  String toJson() => json.encode(toMap());
}
