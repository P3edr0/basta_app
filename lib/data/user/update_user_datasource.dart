import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class UpdateUserDatasource {
  Future<Either<IBasExceptions, bool>> createUser(UserEntity newUser) async {
    try {
      final db = FirebaseFirestore.instance;
      final handledUser = newUser.toMap();

      await db.collection("users").doc(newUser.id).update(handledUser);
      return Right(true);
    } catch (e) {
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
