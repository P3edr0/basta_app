import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/exceptions/exceptions.dart';

class SecureStorageDeleteCredential {
  Future<Either<IBasExceptions, bool>> call() async {
    const storage = FlutterSecureStorage();
    const key = 'login';
    try {
      await storage.delete(key: key);
      return const Right(true);
    } catch (e) {
      log(e.toString());
      return Left(BadRequestJackException());
    }
  }
}
