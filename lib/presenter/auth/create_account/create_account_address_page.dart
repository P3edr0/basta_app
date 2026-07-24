import 'package:flutter/material.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/auth/create_account/store/create_account_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/utils/formatters/cep_formatter.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/dropdowns/secondary_dropdown.dart';
import '../../../components/shines/step_by_step.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';

class CreateAccountAddressPage extends StatefulWidget {
  const CreateAccountAddressPage({super.key});

  @override
  State<CreateAccountAddressPage> createState() =>
      _CreateAccountAddressPageState();
}

class _CreateAccountAddressPageState extends State<CreateAccountAddressPage> {
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
                        title: "Endereço",
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
                          child: BasStepByStep(steps: 3, currentStep: 2),
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
                                      color: primaryColor,

                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.getSize(8)),

                                  Text(
                                    "Endereço",
                                    style: BasFontStyle.h4Bold.copyWith(
                                      color: darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: Responsive.getSize(8)),

                            Column(
                              children: [
                                GiTextfield(
                                  label: "CEP",
                                  controller: controller.postalCodeController,
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
                                        controller: controller.streetController,
                                        hint: "Rua",
                                        validator: (value) {
                                          final handledValue = value as String;

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
                                        controller: controller.numberController,
                                        hint: "N°",
                                        inputType: TextInputType.number,

                                        validator: (value) {
                                          final handledValue = value as String;

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
                                  label: "Complemento (opcional)",
                                  controller: controller.complementController,
                                  hint: "Complemento",
                                ),
                                SizedBox(height: Responsive.getSize(8)),
                                GiTextfield(
                                  label: "Bairro",
                                  controller: controller.neighborhoodController,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: GiTextfield(
                                        label: "Cidade",
                                        controller: controller.cityController,
                                        hint: "Cidade",
                                        validator: (value) {
                                          final handledValue = value as String;

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
                                            style: BasFontStyle.bodyLargeBold
                                                .copyWith(color: grey),
                                          ),
                                          GiSecondaryDropdown(
                                            backgroundButtonColor: mediumGrey,
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

                      SizedBox(height: Responsive.getSize(24)),

                      BasRoundedButton(
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            navigator.goto(BasRoutes.createAccountAttacker);
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
    );
  }
}
