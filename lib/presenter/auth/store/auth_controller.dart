import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/data/local/save_credential.dart';
import 'package:gina/data/user/get_user_datasource.dart';
import 'package:gina/domain/entities/user_entity.dart';

import '../../../data/local/get_credential.dart';

class AuthController extends ChangeNotifier {
  AuthController();
  UserEntity? user;
  String? exception;

  void setUser(UserEntity newUser) {
    user = newUser;
  }

  Future<bool> getUser() async {
    final getCredential = SecureStorageGetCredential();
    final getCredentialResponse = await getCredential();

    return getCredentialResponse.fold(
      (newException) {
        return false;
      },
      (credential) async {
        final getUser = GetUserDatasource();

        final getUserResponse = await getUser(credential);

        return getUserResponse.fold(
          (newException) {
            return false;
          },
          (newUser) {
            user = newUser;
            return true;
          },
        );
      },
    );
  }

  Future<bool> login(String credential) async {
    final getUser = GetUserDatasource();

    final getUserResponse = await getUser(credential);

    return getUserResponse.fold(
      (newException) {
        exception = newException.message;
        log(newException.message);
        return false;
      },
      (newUser) async {
        user = newUser;

        final createCredential = SecureStorageCreateCredential();
        final createCredentialResponse = await createCredential(user!.email);

        return createCredentialResponse.fold(
          (newException) {
            exception = newException.message;

            return false;
          },
          (success) async {
            return true;
          },
        );
      },
    );
  }
}
