import 'package:flutter/material.dart';
import 'package:gina/components/buttons/selector_button.dart';
import 'package:gina/components/dialogs/info_dialog.dart';
import 'package:gina/components/dialogs/options_dialog.dart';
import 'package:gina/components/dialogs/success_dialog.dart';
import 'package:gina/components/loadings/loading.dart';
import 'package:gina/components/textfields/textfield.dart';
import 'package:gina/presenter/guardian/add_guardian/store/add_guardian_controller.dart';
import 'package:gina/presenter/guardian/my_guardians/store/my_guardian_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/utils/enums/guardian_filter_type.dart';
import 'package:gina/utils/enums/guardian_status.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/cards/guardian_card.dart';
import '../../../components/shines/empty_list_animation.dart';
import '../../../theme/colors.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../core/widgets/bottom_navigation_bar.dart';

class AddGuardianPage extends StatefulWidget {
  const AddGuardianPage({super.key});

  @override
  State<AddGuardianPage> createState() => AddGuardianPageState();
}

class AddGuardianPageState extends State<AddGuardianPage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<AddGuardianController>();
      controller.startPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BasBottomNavigationBar(),

      backgroundColor: lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<AddGuardianController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return DashPageLoading();
              }

              final filteredGuardians = controller.filteredGuardians;
              final isEmptyContent = filteredGuardians.isEmpty;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GiAppBar.secondary(title: "Adicionar anjos"),

                    SizedBox(height: Responsive.getSize(16)),
                    Text(
                      "Adicionar anjo",
                      style: BasFontStyle.h4BoldSec.copyWith(color: darkGrey),
                    ),
                    Text(
                      "Encontre pessoas de confiança para fazerem parte da sua rede de proteção",
                      style: BasFontStyle.bodyLargeBold.copyWith(color: grey),
                    ),
                    SizedBox(height: Responsive.getSize(20)),
                    Row(
                      children: [
                        BasSelectorButton(
                          isSelected: controller.guardianFilterType.isAddAngel,
                          title: "Adicionar anjo",
                          onTap:
                              () => controller.setGuardianFilterType(
                                GuardianFilterType.addAngel,
                              ),
                        ),

                        SizedBox(width: Responsive.getSize(30)),
                        BasSelectorButton(
                          isSelected: controller.guardianFilterType.isRequest,
                          title: "Solicitações",
                          onTap:
                              () => controller.setGuardianFilterType(
                                GuardianFilterType.requests,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.getSize(30)),

                    if (controller.guardianFilterType.isAddAngel) ...[
                      GiTextfield(
                        prefix: Icon(
                          Icons.search,
                          size: Responsive.getSize(40),
                          color: darkGrey,
                        ),
                        controller: controller.searchController,
                        onChanged: controller.searchFilter,
                        hint: "Nome do anjo guardião",
                      ),
                      SizedBox(height: Responsive.getSize(16)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Resultados da busca",
                            style: BasFontStyle.bodyLargeBoldSec.copyWith(
                              color: darkGrey,
                            ),
                          ),
                          Text(
                            "${filteredGuardians.length} RESULTADOS",
                            style: BasFontStyle.bodyBold.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(
                      height: Responsive.getSize(isEmptyContent ? 0 : 40),
                    ),
                    if (isEmptyContent)
                      BasEmptyAnimation(
                        content: "Sua lista de anjos guardiões está vazia",
                      ),
                    ...filteredGuardians.map(
                      (guardian) => Padding(
                        padding: EdgeInsets.only(
                          bottom: Responsive.getSize(24),
                        ),
                        child: GuardianCard.tertiary(
                          title: guardian.name,
                          content: guardian.addressResume,
                          image: guardian.image,
                          status: guardian.status,
                          onTap: () async {
                            if (guardian.status!.isWaiting) {
                              InfoDialog.closeAuto(
                                "Aguarde",
                                "Seu convite já foi enviado, aguarde a outra pessoa responder!",
                                context,
                              );
                              return;
                            }
                            if (guardian.status!.isRefused) {
                              InfoDialog.show(
                                "Recusado",
                                "A outra pessoa não aceitou ser seu anjo guardião.",

                                context,
                              );
                              return;
                            }
                            if (guardian.status!.isInvited) {
                              OptionsDialog.show(
                                title: "Pedido",
                                acceptButton: "Aceitar",
                                refuseButton: "Recusar",
                                content:
                                    "${guardian.name} pediu para você se tornar anjo guardião dela",
                                acceptCallback: () async {
                                  await controller.updateGuardianOrder(
                                    orderId: guardian.orderId!,
                                    newStatus: GuardianStatus.accepted,
                                  );
                                  final myGuardianController =
                                      context.read<MyGuardianController>();
                                  myGuardianController.myGuardians.add(
                                    guardian,
                                  );
                                },
                                refuseCallback: () async {
                                  await controller.updateGuardianOrder(
                                    orderId: guardian.orderId!,
                                    newStatus: GuardianStatus.refused,
                                  );
                                },
                                context: context,
                              );
                              return;
                            }
                            if (guardian.status!.isNone) {
                              await controller.addGuardian(
                                receiverId: guardian.id!,
                              );

                              SuccessDialog.show(
                                "Sucesso",
                                "O convite foi enviado com sucesso",

                                context,
                              );
                              return;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
