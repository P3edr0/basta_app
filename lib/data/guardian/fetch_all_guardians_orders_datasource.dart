import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class FetchAllGuardiansOrdersDatasource {
  Future<Either<IBasExceptions, List<GuardianOrderEntity>>> call({
    required String userId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final queryOrdersSnapshot = await db.collection("orders").get();
      final allOrdersData =
          queryOrdersSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      final orders =
          allOrdersData
              .map((order) => GuardianOrderEntity.fromMap(order))
              .toList();
      final handledOrders =
          orders
              .where(
                (order) =>
                    order.receiverId == userId || order.applicantId == userId,
              )
              .toList();

      return Right(handledOrders);
    } catch (e, stack) {
      log("$e => $stack");
      return Left(
        BadRequestJackException(
          message: "Falha buscar pedidos de anjo guardião",
        ),
      );
    }
  }
}
