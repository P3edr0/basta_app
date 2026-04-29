import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class GetUserDatasource {
  Future<Either<IBasExceptions, UserEntity>> call(String credential) async {
    try {
      final db = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await db.collection("users").get();

      final allData =
          querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
      final selectedData = allData.firstWhere(
        (element) => element["email"] == credential,
        orElse: () => {},
      );
      if (selectedData.isEmpty) {
        return Left(
          BadRequestJackException(message: "Credencial não cadastrada"),
        );
      }
      final user = UserEntity.fromMap(selectedData);
      return Right(user);
    } catch (e, stack) {
      log(e.toString());
      log(stack.toString());
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
