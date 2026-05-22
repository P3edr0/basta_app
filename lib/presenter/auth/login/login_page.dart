import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/auth/login/store/login_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/dialogs/quit_app_dialog.dart';
import '../../../components/loadings/loading_button.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../home/home/store/home_controller.dart';
import '../store/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final navigator = AppNavigator();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }

          bool shouldPop = await QuitAppDialog.show(
            'Sair do BASTA?',
            "Deseja sair do BASTA?",
            context,
          );
          if (shouldPop) {
            SystemNavigator.pop();
          }
        },

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getSize(24)),

            child: Column(
              children: [
                GiAppBar.secondary(
                  title: "Entrar",
                  onTap:
                      () => navigator.goto(
                        GiRoutes.createAccount,
                        clearStack: true,
                      ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Consumer<LoginController>(
                        builder: (context, controller, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: Responsive.getSize(16)),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  GiAppAssets.logo,
                                  height: Responsive.getSize(160),
                                ),
                              ),
                              SizedBox(height: Responsive.getSize(16)),

                              Text(
                                "Bem vinda de volta ao BASTA",
                                style: BasFontStyle.titleBoldSec.copyWith(
                                  color: darkGrey,
                                ),
                              ),
                              Text(
                                "Sua segurança em primeiro lugar",
                                style: BasFontStyle.bodyLargeSec.copyWith(
                                  color: grey,
                                ),
                              ),
                              SizedBox(height: Responsive.getSize(16)),

                              Form(
                                key: _formKey,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    Responsive.getSize(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: mediumGrey,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: Responsive.getSize(8)),
                                      GiTextfield(
                                        label: "Email",
                                        controller: controller.emailController,
                                        hint: "ana@gmail.com",
                                        backgroundColor: secondaryColor,
                                        validator: (value) {
                                          if (value.toString().isEmpty) {
                                            return "Insira um email válido";
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: Responsive.getSize(24)),

                                      BasRoundedButton(
                                        onTap: () async {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            controller.setIsLoading(true);
                                            log("Tudo certo com o email");

                                            final authController =
                                                context.read<AuthController>();
                                            final homeController =
                                                context.read<HomeController>();
                                            final credential =
                                                controller.emailController.text;
                                            final hasUser = await authController
                                                .login(credential);
                                            if (hasUser) {
                                              homeController.user =
                                                  authController.user;
                                              controller.emailController
                                                  .clear();
                                              controller.setIsLoading(false);

                                              navigator.goto(
                                                GiRoutes.home,
                                                clearStack: true,
                                              );
                                            } else {
                                              controller.setIsLoading(false);
                                              await ErrorDialog.show(
                                                title: "Atenção",
                                                content:
                                                    "não foi possível realizar o login, por favor tente mais tarde",
                                                context: context,
                                              );
                                            }
                                          }
                                        },
                                        child:
                                            controller.isLoading
                                                ? BasLoadingButton()
                                                : Text(
                                                  "Entrar",
                                                  style: BasFontStyle
                                                      .bodyLargeBoldSec
                                                      .copyWith(
                                                        color: secondaryColor,
                                                      ),
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: Responsive.getSize(24)),
                              InkWell(
                                onTap: () {
                                  navigator.goto(
                                    GiRoutes.createAccount,
                                    clearStack: true,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.getSize(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Não possui uma conta? ",
                                        textAlign: TextAlign.center,
                                        style: BasFontStyle.bodyLargeBold
                                            .copyWith(color: grey),
                                      ),
                                      Text(
                                        "Criar",
                                        textAlign: TextAlign.center,
                                        style: BasFontStyle.bodyLargeBold
                                            .copyWith(color: primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.getSize(24)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
