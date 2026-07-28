import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gina/domain/entities/video_config_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';

class UpdateVideoConfigDatasource {
  Future<Either<IBasExceptions, bool>> call(
    VideoConfigEntity videoConfig,
  ) async {
    try {
      final db = FirebaseFirestore.instance;
      final newVideoConfig = videoConfig.toMap();
      await db
          .collection("video_server")
          .doc(videoConfig.id)
          .update(newVideoConfig);

      return Right(true);
    } catch (e) {
      return Left(
        BadRequestJackException(
          message:
              "Falha ao atualizar dados do servidor de vídeo. Por favor tente mais tarde",
        ),
      );
    }
  }
}
