import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/auth/create_account/store/create_account_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/formatters/br_phone_formatter.dart';
import 'package:gina/utils/formatters/cpf_formatter.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/dialogs/quit_app_dialog.dart';
import '../../../components/shines/step_by_step.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';

class CreateAccountPersonalPage extends StatefulWidget {
  const CreateAccountPersonalPage({super.key});

  @override
  State<CreateAccountPersonalPage> createState() =>
      _CreateAccountPersonalPageState();
}

class _CreateAccountPersonalPageState extends State<CreateAccountPersonalPage> {
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
                          title: "Dados pessoais",
                          onTap:
                              () => navigator.goto(
                                BasRoutes.login,
                                clearStack: true,
                              ),
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
                            child: BasStepByStep(steps: 3, currentStep: 1),
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

                        Row(
                          children: [
                            Container(
                              height: Responsive.getSize(16),
                              width: Responsive.getSize(4),
                              decoration: BoxDecoration(
                                color: primaryColor,

                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SizedBox(width: Responsive.getSize(8)),

                            Text(
                              "Dados pessoais",
                              style: BasFontStyle.h4Bold.copyWith(
                                color: darkGrey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.getSize(16)),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sua foto",
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: grey,
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

                                    controller.setProfileImage(image);
                                  } catch (e) {
                                    ErrorDialog.show(
                                      title: "Atenção",
                                      content:
                                          "Ocorreu um erro ao tentar selecionar imagem. Tente novamente mais tarde",
                                      context: context,
                                    );
                                    log("ERRO=> $e");
                                    setState(() {});
                                  }
                                },
                                child:
                                    controller.profileImage != null
                                        ? CircleAvatar(
                                          radius: Responsive.getSize(86),
                                          backgroundImage: MemoryImage(
                                            controller.profileImage!,
                                          ),
                                        )
                                        : Container(
                                          padding: EdgeInsets.all(
                                            Responsive.getSize(24),
                                          ),

                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,

                                            color: mediumGrey,
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
                                                  color: secondaryColor,
                                                ),
                                                child: Icon(
                                                  BasIcons.camera,
                                                  color: darkGrey,
                                                  size: Responsive.getSize(30),
                                                ),
                                              ),
                                              SizedBox(
                                                height: Responsive.getSize(8),
                                              ),

                                              Text(
                                                "Toque para carregar\n uma imagem",
                                                textAlign: TextAlign.center,
                                                style: BasFontStyle.bodyBold
                                                    .copyWith(color: darkGrey),
                                              ),
                                              SizedBox(
                                                height: Responsive.getSize(8),
                                              ),

                                              Text(
                                                "PNG, JPG até 5MB",
                                                style: BasFontStyle.smallBold
                                                    .copyWith(color: grey),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.getSize(8)),

                        GiTextfield(
                          label: "Nome completo",
                          controller: controller.nameController,
                          hint: "Nome",
                          validator: (value) {
                            final handledValue = value as String;

                            if (!handledValue.contains(" ")) {
                              return "Insira o nome completo";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.getSize(8)),

                        GiTextfield(
                          label: "CPF",
                          controller: controller.documentController,
                          hint: "CPF",
                          inputType: TextInputType.number,

                          formatter: [CpfFormatter.maskFormatter],

                          validator: (value) {
                            final handledValue = value as String;

                            if (handledValue.length != 14) {
                              return "Insira um CPF válido";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.getSize(8)),

                        GiTextfield(
                          label: "Telefone",
                          controller: controller.phoneController,
                          hint: "Telefone",
                          formatter: [BrPhoneInputFormatter()],
                          inputType: TextInputType.number,

                          validator: (value) {
                            final handledValue = value as String;

                            if (handledValue.length < 14) {
                              return "Insira um telefone válido";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.getSize(8)),

                        GiTextfield(
                          label: "Email",
                          controller: controller.emailController,
                          hint: "email",
                          inputType: TextInputType.emailAddress,

                          validator: (value) {
                            final handledValue = value as String;

                            if (handledValue.isEmpty) {
                              return "Insira um email válido";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.getSize(24)),

                        BasRoundedButton(
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              log("Tudo certo com o formulário");
                              if (controller.profileImage == null) {
                                ErrorDialog.show(
                                  title: "Atenção",
                                  content:
                                      controller.exception ??
                                      "Insira uma imagem para ajudar a identificar o usuária em caso de uma emergência",
                                  context: context,
                                );
                                log("Falhou");
                                return;
                              }

                              navigator.goto(BasRoutes.createAccountAddress);
                            }
                          },
                          child: Text(
                            "Avançar",
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
      ),
    );
  }
}
