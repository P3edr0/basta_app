import 'package:flutter/material.dart';
import 'package:gina/presenter/auth/create_account/create_account_page.dart';
import 'package:gina/presenter/auth/login/login_page.dart';
import 'package:gina/presenter/auth/update_user/update_user_page.dart';
import 'package:gina/presenter/guardian/add_guardian/add_guardian_page.dart';
import 'package:gina/presenter/guardian/my_guardians/my_guardian_page.dart';
import 'package:gina/presenter/home/home/home_page.dart';
import 'package:gina/presenter/police_station/police_station/police_station_page.dart';

import '../../presenter/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case == GiRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => SplashPage(),
          settings: settings,
        );
      case == GiRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
          settings: settings,
        );
      case == GiRoutes.login:
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
          settings: settings,
        );
      case == GiRoutes.createAccount:
        return MaterialPageRoute(
          builder: (_) => CreateAccountPage(),
          settings: settings,
        );
      case == GiRoutes.updateUser:
        return MaterialPageRoute(
          builder: (_) => UpdateUserPage(),
          settings: settings,
        );
      case == GiRoutes.guardian:
        return MaterialPageRoute(
          builder: (_) => MyGuardianPage(),
          settings: settings,
        );
      case == GiRoutes.addGuardian:
        return MaterialPageRoute(
          builder: (_) => AddGuardianPage(),
          settings: settings,
        );
      case == GiRoutes.policeStation:
        return MaterialPageRoute(
          builder: (_) => PoliceStationPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),

          settings: settings,
        );
    }
  }
}
