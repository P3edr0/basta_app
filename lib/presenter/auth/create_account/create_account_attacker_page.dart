import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/dialogs/info_dialog.dart';
import 'package:gina/components/loadings/loading_button.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/auth/create_account/store/create_account_controller.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/shines/step_by_step.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../services/url_launcher_service.dart/url_launcher_service.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';
import '../store/auth_controller.dart';

class CreateAccountAttackerPage extends StatefulWidget {
  const CreateAccountAttackerPage({super.key});

  @override
  State<CreateAccountAttackerPage> createState() =>
      _CreateAccountAttackerPageState();
}

class _CreateAccountAttackerPageState extends State<CreateAccountAttackerPage> {
  final navigator = AppNavigator();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getSize(24)),
            child: Form(
              key: _formKey,
              child: Consumer<CreateAccountController>(
                builder: (context, controller, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BasAppBar.secondary(
                        title: "Informações de risco",
                        onTap: () => Navigator.pop(context, true),
                      ),
                      SizedBox(height: Responsive.getSize(16)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            BasAppAssets.logo,
                            height: Responsive.getSize(30),
                          ),
                          SizedBox(width: Responsive.getSize(10)),
                          Text(
                            "BASTA",
                            style: BasFontStyle.h4BoldSec.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.getSize(4)),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: Responsive.getSize(24),
                          child: BasStepByStep(steps: 3, currentStep: 3),
                        ),
                      ),
                      SizedBox(height: Responsive.getSize(16)),

                      Text(
                        "Crie sua rede de proteção.",
                        style: BasFontStyle.h3Bold.copyWith(color: darkGrey),
                      ),
                      Text(
                        "Seus dados criptografados e seguros",
                        style: BasFontStyle.title.copyWith(color: grey),
                      ),
                      SizedBox(height: Responsive.getSize(16)),

                      AnimatedSize(
                        curve: Curves.linear,
                        duration: Duration(milliseconds: 300),

                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.getSize(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: Responsive.getSize(16),
                                    width: Responsive.getSize(4),
                                    decoration: BoxDecoration(
                                      color: accentColor,

                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.getSize(8)),

                                  Text(
                                    "Informações de risco (opcional)",
                                    style: BasFontStyle.h4Bold.copyWith(
                                      color: darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: Responsive.getSize(20),
                              ),
                              padding: EdgeInsets.all(Responsive.getSize(16)),
                              decoration: BoxDecoration(
                                color: mediumGrey,
                                borderRadius: BorderRadius.circular(30),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: Responsive.getSize(10),
                                    ),
                                    child: Text(
                                      "Foto do potencial agressor",
                                      style: BasFontStyle.bodyLargeBold
                                          .copyWith(color: grey),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      setState(() {});
                                      final source = ImageSource.gallery;
                                      try {
                                        final XFile? pickedFile = await _picker
                                            .pickImage(
                                              source: source,
                                              imageQuality: 50,
                                            );

                                        final image =
                                            await pickedFile!.readAsBytes();

                                        controller.setAttackerImage(image);
                                      } catch (e) {
                                        log("ERRO=> $e");
                                        setState(() {});
                                      }
                                    },
                                    child:
                                        controller.attackerImage != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),

                                              child: Image.memory(
                                                controller.attackerImage!,
                                                fit: BoxFit.fitWidth,
                                                height: Responsive.getSize(200),
                                                width: double.infinity,
                                              ),
                                            )
                                            : Container(
                                              padding: EdgeInsets.all(
                                                Responsive.getSize(16),
                                              ),

                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),

                                                color: secondaryColor,
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    padding: EdgeInsets.all(
                                                      Responsive.getSize(10),
                                                    ),

                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: mediumGrey,
                                                    ),
                                                    child: Icon(
                                                      BasIcons.camera,
                                                      color: darkGrey,
                                                      size: Responsive.getSize(
                                                        30,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Responsive.getSize(
                                                      8,
                                                    ),
                                                  ),

                                                  Text(
                                                    "Toque para carregar\n uma imagem",
                                                    textAlign: TextAlign.center,
                                                    style: BasFontStyle.bodyBold
                                                        .copyWith(
                                                          color: darkGrey,
                                                        ),
                                                  ),
                                                  SizedBox(
                                                    height: Responsive.getSize(
                                                      8,
                                                    ),
                                                  ),

                                                  Text(
                                                    "PNG, JPG até 5MB",
                                                    style: BasFontStyle
                                                        .smallBold
                                                        .copyWith(color: grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                  ),

                                  SizedBox(height: Responsive.getSize(8)),
                                  GiTextfield(
                                    label: "Nome do potencial agressor",
                                    controller:
                                        controller.attackerNameController,
                                    hint: "Pedro Caetano",
                                    backgroundColor: secondaryColor,
                                  ),

                                  SizedBox(height: Responsive.getSize(8)),
                                  GiTextfield(
                                    label: "Código da medida protetiva",
                                    controller:
                                        controller.protectionIdController,
                                    hint: "123456789",
                                    backgroundColor: secondaryColor,
                                  ),
                                  SizedBox(height: Responsive.getSize(8)),

                                  Text(
                                    "Esses dados ajudarão as autoridades em caso de acionbamento do alerta",
                                    textAlign: TextAlign.center,
                                    style: BasFontStyle.body.copyWith(
                                      color: grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getSize(24)),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.25,
                            child: Checkbox(
                              activeColor: primaryColor,
                              value: controller.termsAccepted,
                              side: BorderSide(color: grey, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) {
                                controller.setTermsAccepted();
                              },
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: grey,
                                ),
                                children: [
                                  const TextSpan(text: 'Li e concordo com os '),
                                  TextSpan(
                                    text: 'termos de uso',
                                    style: BasFontStyle.bodyLargeBold.copyWith(
                                      color: primaryColor,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () async {
                                            final urlLauncherService =
                                                context
                                                    .read<
                                                      IUrlLauncherService
                                                    >();

                                            await urlLauncherService
                                                .launchCurrentUrl(
                                                  'https://jclartigos.com.br/basta/termosdeuso',
                                                );
                                          },
                                  ),
                                  const TextSpan(text: ' e '),
                                  TextSpan(
                                    text: 'política de privacidade',
                                    style: BasFontStyle.bodyLargeBold.copyWith(
                                      color: primaryColor,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () async {
                                            final urlLauncherService =
                                                context
                                                    .read<
                                                      IUrlLauncherService
                                                    >();

                                            await urlLauncherService
                                                .launchCurrentUrl(
                                                  'https://jclartigos.com.br/basta/privacidade',
                                                );
                                          },
                                  ),
                                  const TextSpan(text: ' do BASTA.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Responsive.getSize(24)),

                      BasRoundedButton(
                        onTap: () async {
                          if (controller.isLoading) {
                            InfoDialog.closeAuto(
                              'Aguarde',
                              "Estamos criando sua conta, isso pode levar alguns segundos",
                              context,
                            );
                            return;
                          }
                          if (!controller.termsAccepted) {
                            ErrorDialog.show(
                              title: 'Atenção',
                              content:
                                  "Você precisa aceitar os termos e condições para criar uma conta",
                              context: context,
                            );
                            return;
                          }
                          if (_formKey.currentState?.validate() ?? false) {
                            log("Tudo certo com o formulário");
                            final notificationService =
                                FirebaseNotificationService();
                            final token = await notificationService.getToken();
                            final response = await controller.createUser(
                              token!,
                            );
                            if (!response) {
                              ErrorDialog.show(
                                title: "Atenção",
                                content:
                                    controller.exception ??
                                    "Ocorreu um erro ao tentar criar sua conta. Tente novamente mais tarde",
                                context: context,
                              );
                              log("Falhou");
                              return;
                            }
                            final authController =
                                context.read<AuthController>();
                            final homeController =
                                context.read<HomeController>();
                            final hasUser = await authController.getUser();
                            if (hasUser) {
                              homeController.user = authController.user;
                              controller.clearFormData();
                              navigator.goto(BasRoutes.home, clearStack: true);
                            } else {
                              if (!response) {
                                ErrorDialog.show(
                                  title: "Atenção",
                                  content:
                                      controller.exception ??
                                      "Ocorreu um erro ao tentar criar sua conta. Tente novamente mais tarde",
                                  context: context,
                                );
                                log("Falhou ao tentar buscar novo usuário");
                                return;
                              }
                            }
                          }
                        },
                        child:
                            controller.isLoading
                                ? BasLoadingButton()
                                : Text(
                                  "Cadastrar",
                                  style: BasFontStyle.bodyLargeBoldSec.copyWith(
                                    color: secondaryColor,
                                  ),
                                ),
                      ),
                      SizedBox(height: Responsive.getSize(24)),
                      InkWell(
                        onTap: () {
                          navigator.goto(BasRoutes.login);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.getSize(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Já possui uma conta? ",
                                textAlign: TextAlign.center,
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: grey,
                                ),
                              ),
                              Text(
                                "Entrar",
                                textAlign: TextAlign.center,
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: primaryColor,
                                ),
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
      ),
    );
  }
}
