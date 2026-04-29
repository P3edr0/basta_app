import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class DeleteGuardianOrderDatasource {
  Future<Either<IBasExceptions, bool>> call(String orderId) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection("orders").doc(orderId).delete();

      return Right(true);
    } catch (e) {
      return Left(
        BadRequestJackException(
          message: "Falha ao remover anjo. Por favor tente mais tarde",
        ),
      );
    }
  }
}
