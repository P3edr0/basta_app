import 'package:gina/presenter/auth/create_account/store/create_account_controller.dart';
import 'package:gina/presenter/auth/login/store/login_controller.dart';
import 'package:gina/presenter/auth/store/auth_controller.dart';
import 'package:gina/presenter/core/store/core_controller.dart';
import 'package:gina/presenter/guardian/add_guardian/store/add_guardian_controller.dart';
import 'package:gina/presenter/guardian/my_guardians/store/my_guardian_controller.dart';
import 'package:provider/provider.dart';

import '../presenter/auth/update_user/store/update_user_controller.dart';
import '../presenter/guardian/store/guardian_controller.dart';
import '../presenter/home/home/store/home_controller.dart';
import '../services/cep_service/cep_service.dart';
import '../services/cep_service/cep_service_impl.dart';

class Providers {
  static final providers = [
    ////////////////// CORE //////////////////
    ChangeNotifierProvider<CoreController>(create: (ctx) => CoreController()),

    ////////////////// SERVICES //////////////////
    // CEP SERVICE /////////
    Provider<ICepService>(create: (ctx) => ViaCepService()),

    ////////////////// AUTH //////////////////
    ChangeNotifierProvider<AuthController>(create: (ctx) => AuthController()),
    ChangeNotifierProvider<LoginController>(create: (ctx) => LoginController()),
    ChangeNotifierProvider<CreateAccountController>(
      create:
          (ctx) => CreateAccountController(cepService: ctx.read<ICepService>()),
    ),
    ChangeNotifierProvider<UpdateUserController>(
      create:
          (ctx) => UpdateUserController(cepService: ctx.read<ICepService>()),
    ),
    ChangeNotifierProvider<HomeController>(create: (_) => HomeController()),

    ////////////////// GUARDIAN //////////////////
    ChangeNotifierProvider<MyGuardianController>(
      create: (ctx) => MyGuardianController(),
    ),
    ChangeNotifierProvider<AddGuardianController>(
      create: (ctx) => AddGuardianController(),
    ),
    ChangeNotifierProvider<GuardianController>(
      create:
          (ctx) => GuardianController(
            addGuardianController: ctx.read<AddGuardianController>(),
            myGuardianController: ctx.read<MyGuardianController>(),
          ),
    ),
  ];
}
