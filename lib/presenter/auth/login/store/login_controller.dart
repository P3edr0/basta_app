import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  LoginController();

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String? exception;

  /////////////////////////////////// GETS
  bool get hasError => exception != null;

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }
}
