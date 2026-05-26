// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:gina/domain/entities/guardian_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyHistoryEntity {
  final GuardianEntity? guardian;
  final List<LatLng> positions;
  final String status;
  final String victimId;
  final DateTime date;

  EmergencyHistoryEntity({
    this.guardian,
    required this.victimId,
    required this.positions,
    required this.status,
    required this.date,
  });

  factory EmergencyHistoryEntity.fromMap(Map<String, dynamic> map) {
    final locations = Map<String, dynamic>.from(map['locations']);
    final handledLocations =
        locations.values.map((loc) {
          return LatLng(loc['latitude'] as double, loc['longitude'] as double);
        }).toList();
    return EmergencyHistoryEntity(
      victimId: map['victimId'] as String,
      positions: handledLocations,
      status: map['status'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  factory EmergencyHistoryEntity.fromJson(String source) =>
      EmergencyHistoryEntity.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  EmergencyHistoryEntity copyWith({
    GuardianEntity? guardian,
    List<LatLng>? positions,
    String? status,
    String? victimId,
    DateTime? date,
  }) {
    return EmergencyHistoryEntity(
      guardian: guardian ?? this.guardian,
      positions: positions ?? this.positions,
      status: status ?? this.status,
      victimId: victimId ?? this.victimId,
      date: date ?? this.date,
    );
  }
}
