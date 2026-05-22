import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/loadings/loading_button.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/auth/create_account/store/create_account_controller.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/formatters/br_phone_formatter.dart';
import 'package:gina/utils/formatters/cep_formatter.dart';
import 'package:gina/utils/formatters/cpf_formatter.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/dialogs/quit_app_dialog.dart';
import '../../../components/dropdowns/secondary_dropdown.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';
import '../store/auth_controller.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
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
                        Row(
                          children: [
                            Image.asset(
                              GiAppAssets.logo,
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
                        SizedBox(height: Responsive.getSize(16)),

                        Text(
                          "Crie sua rede de proteção.",
                          style: BasFontStyle.titleBoldSec.copyWith(
                            color: darkGrey,
                          ),
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
                              style: BasFontStyle.titleBold.copyWith(
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
                                                "PNG, JPG até 400KB",
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

                            if (handledValue.isNotEmpty &&
                                handledValue.length != 14) {
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

                        AnimatedSize(
                          curve: Curves.linear,
                          duration: Duration(milliseconds: 300),

                          child: Column(
                            children: [
                              InkWell(
                                onTap: controller.setShowAddress,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.getSize(8),
                                  ),

                                  child: Row(
                                    children: [
                                      Container(
                                        height: Responsive.getSize(16),
                                        width: Responsive.getSize(4),
                                        decoration: BoxDecoration(
                                          color: primaryColor,

                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Responsive.getSize(8)),

                                      Text(
                                        "Endereço",
                                        style: BasFontStyle.titleBold.copyWith(
                                          color: darkGrey,
                                        ),
                                      ),
                                      Spacer(),
                                      AnimatedRotation(
                                        turns: controller.showAddress ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: Icon(
                                          Icons
                                              .keyboard_double_arrow_down_outlined,
                                          size: Responsive.getSize(24),
                                          color:
                                              controller.showAddress
                                                  ? primaryColor
                                                  : grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: Responsive.getSize(8)),

                              if (controller.showAddress)
                                Column(
                                  children: [
                                    GiTextfield(
                                      label: "CEP",
                                      controller:
                                          controller.postalCodeController,
                                      hint: "00000-000",
                                      formatter: [CepFormatter.maskFormatter],
                                      inputType: TextInputType.number,

                                      validator: (value) {
                                        if (value.length < 9) {
                                          return 'Insira um CEP válido.';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) async {
                                        if (value.length < 9) return;
                                        await controller.getCep(value);
                                      },
                                    ),

                                    SizedBox(height: Responsive.getSize(8)),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: GiTextfield(
                                            label: "Rua",
                                            controller:
                                                controller.streetController,
                                            hint: "Rua",
                                            validator: (value) {
                                              final handledValue =
                                                  value as String;

                                              if (handledValue.isEmpty) {
                                                return "Insira uma rua válida";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: Responsive.getSize(8)),

                                        Expanded(
                                          child: GiTextfield(
                                            label: "N°",
                                            controller:
                                                controller.numberController,
                                            hint: "N°",
                                            inputType: TextInputType.number,

                                            validator: (value) {
                                              final handledValue =
                                                  value as String;

                                              if (handledValue.isEmpty) {
                                                return "Insira um número válida";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: Responsive.getSize(8)),
                                    GiTextfield(
                                      label: "Complemento",
                                      controller:
                                          controller.complementController,
                                      hint: "Complemento",
                                    ),
                                    SizedBox(height: Responsive.getSize(8)),
                                    GiTextfield(
                                      label: "Bairro",
                                      controller:
                                          controller.neighborhoodController,
                                      hint: "Bairro",
                                      validator: (value) {
                                        final handledValue = value as String;

                                        if (handledValue.isEmpty) {
                                          return "Insira um bairro válido";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Responsive.getSize(8)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: GiTextfield(
                                            label: "Cidade",
                                            controller:
                                                controller.cityController,
                                            hint: "Cidade",
                                            validator: (value) {
                                              final handledValue =
                                                  value as String;

                                              if (handledValue.isEmpty) {
                                                return "Insira uma cidade válida";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: Responsive.getSize(8)),

                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Text(
                                                "Estado",
                                                style: BasFontStyle
                                                    .bodyLargeBold
                                                    .copyWith(color: grey),
                                              ),
                                              GiSecondaryDropdown(
                                                backgroundButtonColor:
                                                    mediumGrey,
                                                isUnderlineBorder: false,
                                                height: 56,
                                                fontSize: 14,
                                                contentColor: primaryColor,
                                                selectedItem:
                                                    controller.selectedState,
                                                onChanged: (value) {
                                                  controller.setSelectedState(
                                                    value!,
                                                  );
                                                },
                                                items: controller.states,

                                                textColor: blueGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.getSize(16)),

                        AnimatedSize(
                          curve: Curves.linear,
                          duration: Duration(milliseconds: 300),

                          child: Column(
                            children: [
                              InkWell(
                                onTap: controller.setShowRiskInfo,
                                child: Padding(
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

                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Responsive.getSize(8)),

                                      Text(
                                        "Informações de risco",
                                        style: BasFontStyle.titleBold.copyWith(
                                          color: darkGrey,
                                        ),
                                      ),
                                      Spacer(),
                                      AnimatedRotation(
                                        turns:
                                            controller.showRiskInfo ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: Icon(
                                          Icons
                                              .keyboard_double_arrow_down_outlined,
                                          size: Responsive.getSize(24),
                                          color:
                                              controller.showRiskInfo
                                                  ? accentColor
                                                  : grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (controller.showRiskInfo)
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: Responsive.getSize(20),
                                  ),
                                  padding: EdgeInsets.all(
                                    Responsive.getSize(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: mediumGrey,
                                    borderRadius: BorderRadius.circular(30),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: Responsive.getSize(16)),
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
                                            final XFile? pickedFile =
                                                await _picker.pickImage(
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
                                                    height: Responsive.getSize(
                                                      200,
                                                    ),
                                                    width: double.infinity,
                                                  ),
                                                )
                                                : Container(
                                                  padding: EdgeInsets.all(
                                                    Responsive.getSize(16),
                                                  ),

                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),

                                                    color: secondaryColor,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.all(
                                                          Responsive.getSize(
                                                            10,
                                                          ),
                                                        ),

                                                        decoration:
                                                            BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color: mediumGrey,
                                                            ),
                                                        child: Icon(
                                                          BasIcons.camera,
                                                          color: darkGrey,
                                                          size:
                                                              Responsive.getSize(
                                                                30,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            Responsive.getSize(
                                                              8,
                                                            ),
                                                      ),

                                                      Text(
                                                        "Toque para carregar\n uma imagem",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: BasFontStyle
                                                            .bodyBold
                                                            .copyWith(
                                                              color: darkGrey,
                                                            ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            Responsive.getSize(
                                                              8,
                                                            ),
                                                      ),

                                                      Text(
                                                        "PNG, JPG até 400KB",
                                                        style: BasFontStyle
                                                            .smallBold
                                                            .copyWith(
                                                              color: grey,
                                                            ),
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

                        BasRoundedButton(
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              log("Tudo certo com o formulário");
                              final response = await controller.createUser();
                              if (!response) {
                                ErrorDialog.show(
                                  title: "Atenção",
                                  content: controller.exception ??
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
                                navigator.goto(GiRoutes.home, clearStack: true);
                              } else {
                                log("Falha ao buscar novo usuário");
                              }
                            }
                          },
                          child:
                              controller.isLoading
                                  ? BasLoadingButton()
                                  : Text(
                                    "Cadastrar",
                                    style: BasFontStyle.bodyLargeBoldSec
                                        .copyWith(color: secondaryColor),
                                  ),
                        ),
                        SizedBox(height: Responsive.getSize(24)),
                        InkWell(
                          onTap: () {
                            navigator.goto(GiRoutes.login);
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
