import 'package:flutter/material.dart';
import 'package:gina/presenter/auth/create_account/create_account_personal_page.dart';
import 'package:gina/presenter/auth/login/login_page.dart';
import 'package:gina/presenter/auth/update_user/update_user_page.dart';
import 'package:gina/presenter/guardian/add_guardian/add_guardian_page.dart';
import 'package:gina/presenter/guardian/emergency_history/emergency_history_page.dart';
import 'package:gina/presenter/guardian/my_guardians/my_guardian_page.dart';
import 'package:gina/presenter/home/call/call_page.dart';
import 'package:gina/presenter/home/home/home_page.dart';
import 'package:gina/presenter/police_station/police_station/police_station_page.dart';

import '../../presenter/auth/create_account/create_account_address_page.dart';
import '../../presenter/auth/create_account/create_account_attacker_page.dart';
import '../../presenter/guardian/emergency_details/emergency_details_page.dart';
import '../../presenter/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case == BasRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => SplashPage(),
          settings: settings,
        );
      case == BasRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
          settings: settings,
        );
      case == BasRoutes.login:
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
          settings: settings,
        );
      case == BasRoutes.createAccountPersonal:
        return MaterialPageRoute(
          builder: (_) => CreateAccountPersonalPage(),
          settings: settings,
        );
      case == BasRoutes.createAccountAddress:
        return MaterialPageRoute(
          builder: (_) => CreateAccountAddressPage(),
          settings: settings,
        );
      case == BasRoutes.createAccountAttacker:
        return MaterialPageRoute(
          builder: (_) => CreateAccountAttackerPage(),
          settings: settings,
        );
      case == BasRoutes.updateUser:
        return MaterialPageRoute(
          builder: (_) => UpdateUserPage(),
          settings: settings,
        );
      case == BasRoutes.guardian:
        return MaterialPageRoute(
          builder: (_) => MyGuardianPage(),
          settings: settings,
        );
      case == BasRoutes.addGuardian:
        return MaterialPageRoute(
          builder: (_) => AddGuardianPage(),
          settings: settings,
        );
      case == BasRoutes.policeStation:
        return MaterialPageRoute(
          builder: (_) => PoliceStationPage(),
          settings: settings,
        );
      case == BasRoutes.emergencyHistory:
        return MaterialPageRoute(
          builder: (_) => EmergencyHistoryPage(),
          settings: settings,
        );
      case == BasRoutes.emergencyDetails:
        return MaterialPageRoute(
          builder: (_) => EmergencyDetailsPage(),
          settings: settings,
        );
      case == BasRoutes.call:
        return MaterialPageRoute(
          builder: (_) => CallPage(),
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
