import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gina/domain/entities/emergency_history_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class FetchEmergencyHistoryDatasource {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<Either<IBasExceptions, List<EmergencyHistoryEntity>>> call({
    required String userId,
    required List<String> guardians,
  }) async {
    try {
      final allIds = [userId, ...guardians];

      List<EmergencyHistoryEntity> emergencies = [];

      for (var id in allIds) {
        DatabaseReference emergencyRef = _db.ref("emergencies/$id");
        final emergencyData = await emergencyRef.get();

        Map<dynamic, dynamic> emergencyHistoryData =
            emergencyData.value as Map<dynamic, dynamic>;
        final newEmergency =
            emergencyHistoryData.entries
                .map(
                  (emergency) => EmergencyHistoryEntity.fromMap(
                    Map<String, dynamic>.from({
                      ...emergency.value,
                      "victimId": id,
                    }),
                  ),
                )
                .toList();
        emergencies.addAll(newEmergency);
      }
      return Right(emergencies);
    } catch (e, stack) {
      log("Erro no fallback de localização: $e");
      log("Stack trace: $stack");
    }
    return Left(BadRequestJackException());
  }
}
