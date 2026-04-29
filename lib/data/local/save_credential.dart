import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/exceptions/exceptions.dart';

class SecureStorageCreateCredential {
  Future<Either<IBasExceptions, bool>> call(String credential) async {
    const storage = FlutterSecureStorage();
    const key = 'login';
    try {
      await storage.delete(key: key);
      await storage.write(key: key, value: credential);
      return const Right(true);
    } catch (e) {
      log(e.toString());
      return Left(BadRequestJackException());
    }
  }
}
