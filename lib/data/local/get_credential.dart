import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/exceptions/exceptions.dart';

class SecureStorageGetCredential {
  Future<Either<IBasExceptions, String>> call() async {
    const storage = FlutterSecureStorage();
    const key = 'login';
    try {
      final credential = await storage.read(key: key);
      if (credential == null) {
        return Left(
          BadRequestJackException(message: "Não existe credencial cadastrada"),
        );
      }
      return Right(credential);
    } catch (e) {
      log(e.toString());
      return Left(
        BadRequestJackException(message: "Não existe credencial cadastrada"),
      );
    }
  }
}
