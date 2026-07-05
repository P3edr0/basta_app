import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class DeleteUserDatasource {
  final storage = FirebaseStorage.instance;

  Future<Either<IBasExceptions, bool>> call(String userId) async {
    try {
      final db = FirebaseFirestore.instance;

      await db.collection("users").doc(userId).update({'active': false});
      return Right(true);
    } catch (e, stackTrace) {
      log("Erro ao atualizar usuário: $e");
      log("Stack trace: $stackTrace");
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
