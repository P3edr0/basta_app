import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/guardian_entity.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';
import 'package:gina/utils/enums/guardian_status.dart';

class FetchAllGuardiansDatasource {
  Future<Either<IBasExceptions, List<GuardianEntity>>> call({
    required String userId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final querySnapshot = await db.collection("users").get();
      final allData =
          querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

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
      final guardians =
          allData.map((guardian) => GuardianEntity.fromMap(guardian)).toList();

      for (var order in orders) {
        for (var index = 0; index < guardians.length; index++) {
          if (order.applicantId == userId &&
              order.receiverId == guardians[index].id) {
            guardians[index] = guardians[index].copyWith(
              status: GuardianStatus.waiting,
              orderId: order.id,
            );
            if (order.answer == true) {
              guardians[index] = guardians[index].copyWith(
                status: GuardianStatus.accepted,
                orderId: order.id,
              );
            }
          } else if (order.receiverId == userId &&
              order.applicantId == guardians[index].id) {
            guardians[index] = guardians[index].copyWith(
              status: GuardianStatus.invited,
              orderId: order.id,
            );
            if (order.answer == true) {
              guardians[index] = guardians[index].copyWith(
                status: GuardianStatus.accepted,
                orderId: order.id,
              );
            }
            if (order.answer == false) {
              guardians[index] = guardians[index].copyWith(
                status: GuardianStatus.refused,
                orderId: order.id,
              );
            }
          }
        }
      }

      return Right(guardians);
    } catch (e, stack) {
      log("$e => $stack");
      return Left(
        BadRequestJackException(message: "Falha ao fazer criação de usuária"),
      );
    }
  }
}
