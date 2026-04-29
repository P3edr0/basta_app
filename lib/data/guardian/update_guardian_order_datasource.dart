import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class UpdateGuardianOrderDatasource {
  Future<Either<IBasExceptions, bool>> call(GuardianOrderEntity order) async {
    try {
      final db = FirebaseFirestore.instance;
      final newOrder = order.toMap();
      await db.collection("orders").doc(order.id).update(newOrder);

      return Right(true);
    } catch (e) {
      return Left(
        BadRequestJackException(
          message: "Falha ao responder convite. Por favor tente mais tarde",
        ),
      );
    }
  }
}
