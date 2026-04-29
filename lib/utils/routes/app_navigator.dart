import 'package:flutter/material.dart';

import '../../../main.dart';

class AppNavigator {
  AppNavigator();

  Future<void> _push(String route, {Object? args}) {
    return navigatorKey.currentState!.pushNamed(route, arguments: args);
  }

  Future<void> _replace(String route, {Object? args}) {
    return navigatorKey.currentState!.pushReplacementNamed(route, arguments: args);
  }

  Future<void> _clearStack(String route, {Object? args}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (route) => false, arguments: args);
  }

  Future<void> _pushAndRemoveUntil(String route, String untilRoute, {Object? args}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(route, ModalRoute.withName(untilRoute), arguments: args);
  }

  Future<void> goto(
    String route, {
    bool push = false,
    bool replace = false,
    bool clearStack = false,
    String? removeUntilRoute,
    Object? args,
  }) async {
    if (clearStack) {
      await _clearStack(route, args: args);
      return;
    }

    if (removeUntilRoute != null) {
      await _pushAndRemoveUntil(route, removeUntilRoute, args: args);
      return;
    }

    if (replace) {
      await _replace(route, args: args);
      return;
    }

    await _push(route, args: args);
  }
}
