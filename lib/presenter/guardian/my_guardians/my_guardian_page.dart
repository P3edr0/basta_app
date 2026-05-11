import 'package:flutter/material.dart';
import 'package:gina/presenter/core/widgets/bottom_navigation_bar.dart';
import 'package:gina/presenter/guardian/my_guardians/store/my_guardian_controller.dart';
import 'package:gina/presenter/guardian/store/guardian_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/cards/guardian_card.dart';
import '../../../components/dialogs/invite_dialog.dart';
import '../../../components/loadings/loading.dart';
import '../../../components/shines/empty_list_animation.dart';
import '../../../theme/colors.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../auth/store/auth_controller.dart';

class MyGuardianPage extends StatefulWidget {
  const MyGuardianPage({super.key});

  @override
  State<MyGuardianPage> createState() => MyGuardianPageState();
}

class MyGuardianPageState extends State<MyGuardianPage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = context.read<AuthController>();
      final controller = context.read<GuardianController>();
      final user = authController.user!;
      controller.setUserId(user);
      await controller.startPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      bottomNavigationBar: BasBottomNavigationBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<MyGuardianController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return DashPageLoading();
              }
              final isEmptyContent = controller.myGuardians.isEmpty;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GiAppBar.secondary(title: "Meus Anjos Guardiões"),

                    SizedBox(height: Responsive.getSize(16)),
                    Text(
                      "Círculo de Proteção",
                      style: BasFontStyle.h4BoldSec.copyWith(color: darkGrey),
                    ),
                    Text(
                      "Estas são as pessoas que receberão um alerta em caso de emergência",
                      style: BasFontStyle.bodyLargeBold.copyWith(color: grey),
                    ),
                    SizedBox(height: Responsive.getSize(30)),

                    AngelCard(
                      icon: Icons.add,
                      title: "+ Adicionar novo anjo",
                      content: "Convide uma pessoa de confiança",
                      onTap: () {
                        navigator.goto(GiRoutes.addGuardian);
                      },
                    ),
                    SizedBox(height: Responsive.getSize(30)),
                    if (isEmptyContent)
                      BasEmptyAnimation(
                        content: "Sua lista de anjos guardiões está vazia",
                      ),

                    ...controller.myGuardians.map(
                      (guardian) => AngelCard.secondary(
                        title: guardian.name,
                        content: "Pronta para ajudar",
                        image: guardian.image,
                        onTap: () {
                          InviteDialog.show(
                            title: "Remover",
                            refuseButton: "Cancelar",
                            acceptButton: "Remover",
                            content:
                                "Você deseja remover ${guardian.name} como seu anjo guardião?",
                            acceptCallback: () async {
                              await controller.deleteGuardianOrder(
                                orderId: guardian.orderId!,
                              );
                            },
                            refuseCallback: () async {},
                            context: context,
                          );
                          return;
                        },
                      ),
                    ),
                    if (!isEmptyContent)
                      Container(
                        decoration: BoxDecoration(
                          color: mediumGrey,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: primaryColor),
                            Text(
                              "Você pode ter até 5 anjos guardiões.",
                              style: BasFontStyle.body.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ],
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
