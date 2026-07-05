import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  LoginController();

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  /////////////////////////////////// GETS

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }
}
