import 'dart:developer';

import 'package:flutter/material.dart';

import 'app_routes.dart';

class RouteStackObserver extends NavigatorObserver with ChangeNotifier {
  RouteStackObserver._();
  factory RouteStackObserver.instance() {
    _instance ??= RouteStackObserver._();

    return _instance!;
  }

  static RouteStackObserver? _instance;
  final List<Route<dynamic>> _routeStack = [];

  List<Route<dynamic>> get currentStack => List.unmodifiable(_routeStack);
  List<String?> get currentStackNames =>
      _routeStack.map((element) => element.settings.name).toList();
  String? get currentRoute =>
      _routeStack.map((element) => element.settings.name).toList().last;

  @override
  void didPush(Route route, Route? previousRoute) {
    _routeStack.add(route);
    for (var route in _routeStack) {
      debugPrint(route.settings.name);
    }
    log('Pushed: ${route.settings.name}');
    if (route.settings.name == BasRoutes.home) {
      changeCurrentPage(2);
    }
    if (route.settings.name == BasRoutes.policeStation) {
      changeCurrentPage(1);
    }
    if (route.settings.name == BasRoutes.addGuardian ||
        route.settings.name == BasRoutes.emergencyDetails ||
        route.settings.name == BasRoutes.guardian) {
      changeCurrentPage(3);
    }
    if (route.settings.name == BasRoutes.updateUser) {
      changeCurrentPage(4);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _routeStack.remove(route);
    log('Popped: ${route.settings.name}');

    if (previousRoute?.settings.name == BasRoutes.policeStation) {
      changeCurrentPage(1);
    }
    if (previousRoute?.settings.name == BasRoutes.home) {
      changeCurrentPage(2);
    }
    if (previousRoute?.settings.name == BasRoutes.addGuardian ||
        previousRoute?.settings.name == BasRoutes.guardian ||
        previousRoute?.settings.name == BasRoutes.emergencyDetails) {
      changeCurrentPage(3);
    }
    if (previousRoute?.settings.name == BasRoutes.updateUser) {
      changeCurrentPage(4);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _routeStack.remove(route);
    log('Removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) _routeStack.remove(oldRoute);
    if (newRoute != null) _routeStack.add(newRoute);
    log('Replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }

  int currentPageindex = 2;

  void changeCurrentPage(int newPageIndex) {
    currentPageindex = newPageIndex;
    notifyListeners();
  }
}
