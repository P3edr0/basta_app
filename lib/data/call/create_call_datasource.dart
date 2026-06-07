import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gina/domain/entities/call_data_entity.dart';
import 'package:gina/domain/exceptions/exceptions.dart';
import 'package:gina/utils/framework/environment.dart';

class CreateCallDatasource {
  Future<Either<IBasExceptions, CallDataEntity>> call(String roomName) async {
    try {
      var headers = {
        'X-Sandbox-ID': Environment.videoId,
        'Content-Type': 'application/json',
      };
      var data = json.encode({"room_name": roomName});
      var dio = Dio();
      var response = await dio.request(
        Environment.videoUrl,
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final call = CallDataEntity.fromMap(data);
        return Right(call);
      } else {
        log(response.statusMessage.toString());
        return Left(
          BadRequestJackException(message: "Falha ao fazer de chamada"),
        );
      }
    } catch (e) {
      return Left(
        BadRequestJackException(message: "Falha ao fazer de chamada"),
      );
    }
  }
}
