import 'package:flutter/material.dart';
import 'package:gina/presenter/auth/store/auth_controller.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:provider/provider.dart';

import '../../../responsiveness/responsive.dart';
import '../../theme/colors.dart';
import '../../utils/assets/app_assets.dart';
import '../../utils/routes/app_navigator.dart';
import '../../utils/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      Responsive.defineSize(size, pixelRatio: size.aspectRatio);
      final authController = context.read<AuthController>();
      final homeController = context.read<HomeController>();
      final hasUser = await authController.getUser();
      if (hasUser) {
        homeController.user = authController.user;
      }
      redirect(hasUser);
    });
  }

  redirect(bool hasUser) async {
    if (hasUser) {
      navigator.goto(GiRoutes.home, clearStack: true);
      return;
    }

    navigator.goto(GiRoutes.createAccount, clearStack: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(Responsive.getSize(30)),
                child: Image.asset(
                  colorBlendMode: BlendMode.hardLight,
                  GiAppAssets.logo,
                ),
              ),
              Text(
                "BASTA",
                style: BasFontStyle.h2BoldSec.copyWith(color: primaryColor),
              ),
              Text(
                "Sua segurança em primeiro lugar",
                style: BasFontStyle.h4Bold.copyWith(color: grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
