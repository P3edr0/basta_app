import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/video_config_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class FetchVideoConfigDatasource {
  Future<Either<IBasExceptions, VideoConfigEntity>> call() async {
    try {
      final db = FirebaseFirestore.instance;

      final querySnapshot = await db.collection("video_server").get();
      final videoConfigData =
          querySnapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;
                return data;
              })
              .toList()
              .first;

      final config = VideoConfigEntity.fromMap(videoConfigData);

      return Right(config);
    } catch (e, stack) {
      log("$e => $stack");
      return Left(
        BadRequestJackException(
          message: "Falha ao fazer busca dos dados do servidor",
        ),
      );
    }
  }
}
