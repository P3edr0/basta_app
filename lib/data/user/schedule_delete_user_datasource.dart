import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class ScheduleDeleteUserDatasource {
  final storage = FirebaseStorage.instance;

  Future<Either<IBasExceptions, bool>> call({
    required String userId,
    required DateTime schedule,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final date = schedule.millisecondsSinceEpoch;
      await db.collection("users").doc(userId).update({
        'scheduleToDelete': date,
      });
      return Right(true);
    } catch (e, stackTrace) {
      log("Erro ao definir agendamento: $e");
      log("Stack trace: $stackTrace");
      return Left(
        BadRequestJackException(message: "Falha ao fazer agendamento"),
      );
    }
  }
}
