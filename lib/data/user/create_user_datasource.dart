import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class CreateUserDatasource {
  Future<Either<IBasExceptions, bool>> createUser(UserEntity newUser) async {
    try {
      final db = FirebaseFirestore.instance;
      final user = newUser.toMap();

      await db
          .collection("users")
          .add(user)
          .then((DocumentReference doc) => log('ID NOVO USUÁRIO: ${doc.id}'));
      return Right(true);
    } catch (e) {
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
