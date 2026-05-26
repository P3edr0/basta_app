import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/components/dialogs/info_dialog.dart';
import 'package:gina/presenter/auth/store/auth_controller.dart';
import 'package:gina/presenter/auth/update_user/store/update_user_controller.dart';
import 'package:gina/presenter/guardian/emergency_details/store/emergency_details_controller.dart';
import 'package:gina/presenter/guardian/store/guardian_controller.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/handler/name_handler.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/cards/home_card.dart';
import '../../../components/dialogs/emergency_dialog.dart';
import '../../../components/dialogs/quit_app_dialog.dart';
import '../../../data/emergency/guardian_tracking_datasource.dart';
import '../../../main.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/enums/emergency_status.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../core/widgets/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final guardianTracking = GuardianTrackingDataSource();
      final authController = context.read<AuthController>();

      guardianTracking.call(
        userId: authController.user!.id!,
        protectedVictimsIds: authController.user?.myGuardians ?? [],

        onEmergencyDetected: (victimId, emergencyId) {
          final navigatorContext = navigatorKey.currentContext;
          if (navigatorContext == null) return;
          final guardiansController =
              navigatorContext.read<GuardianController>();
          final emergencyDetailsController =
              navigatorContext.read<EmergencyDetailsController>();

          if (guardiansController.emergencyActivated) return;
          guardiansController.setEmergencyActivated(true);
          final guardian = guardiansController.allGuardians.firstWhere(
            (guard) => guard.id == victimId,
          );
          emergencyDetailsController.setEmergencyData(emergencyId, guardian);

          EmergencyDialog.show(
            "Atenção",
            "${guardian.name} acionou o botão de emergência!\nAcompanhe a localização dela em tempo real.",
            context,
            () {
              emergencyDetailsController.setIsEmergency(
                true,
                EmergencyStatus.active,
              );
              navigator.goto(GiRoutes.emergencyDetails);
            },
          );
        },
      );
      final controller = context.read<HomeController>();
      await controller.getCurrentAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BasBottomNavigationBar(),
      backgroundColor: primaryColor,
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
            child: Consumer<HomeController>(
              builder: (context, controller, child) {
                final bool hasImage = controller.user?.image != null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSize(24),
                        vertical: Responsive.getSize(8),
                      ),
                      color: secondaryColor,
                      child: Row(
                        children: [
                          InkWell(
                            onTap:
                                () => InfoDialog.closeAuto(
                                  "Em breve...",
                                  "Estamos desenvolvendo esta funcionalidade.",
                                  context,
                                ),
                            child: Icon(
                              Icons.menu,
                              size: Responsive.getSize(30),
                            ),
                          ),
                          SizedBox(width: Responsive.getSize(5)),
                          Text(
                            "BASTA",
                            style: BasFontStyle.titleBoldSec.copyWith(
                              color: primaryColor,
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              final authController =
                                  context.read<AuthController>();
                              final updateUserController =
                                  context.read<UpdateUserController>();
                              final user = authController.user;
                              updateUserController.setUser(user);
                              navigator.goto(GiRoutes.updateUser);
                            },

                            child: CircleAvatar(
                              radius: Responsive.getSize(20),
                              backgroundColor: primaryFocusColor,
                              backgroundImage:
                                  hasImage
                                      ? NetworkImage(controller.user!.image!)
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSize(24),
                        vertical: Responsive.getSize(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            controller.tabs.map((item) {
                              return InkWell(
                                onTap:
                                    () => InfoDialog.closeAuto(
                                      "Em breve...",
                                      "Estamos desenvolvendo esta funcionalidade.",
                                      context,
                                    ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        Responsive.getSize(10),
                                      ),
                                      decoration: BoxDecoration(
                                        color: secondaryColor,

                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: Responsive.getSize(24),
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.getSize(4)),
                                    Text(
                                      item.name,
                                      style: BasFontStyle.smallBold.copyWith(
                                        color: secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSize(24),
                        vertical: Responsive.getSize(4),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Responsive.getSize(16)),
                          Text(
                            "Olá, ${NameHandler.firstName(controller.user?.name ?? "Usuária")}",
                            style: BasFontStyle.h4BoldSec.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                          Text(
                            "Você está em um lugar seguro",
                            style: BasFontStyle.bodyLargeBold.copyWith(
                              color: lightGrey,
                            ),
                          ),
                          SizedBox(height: Responsive.getSize(40)),

                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap:
                                  () async => await controller.startEmergency(),
                              child: CircleAvatar(
                                backgroundColor: secondaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                radius: Responsive.getSize(120),

                                child: CircleAvatar(
                                  radius: Responsive.getSize(100),
                                  backgroundColor: secondaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: secondaryColor,

                                    radius: Responsive.getSize(80),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(GiAppAssets.emergency),
                                        SizedBox(height: Responsive.getSize(8)),

                                        Text(
                                          "EMERGÊNCIA",
                                          style: BasFontStyle.titleBoldSec
                                              .copyWith(color: primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.getSize(20)),
                          BasRoundedButton(
                            child: Text("Psicóloga de Plantão"),
                            onTap: () => controller.stopEmergency(),
                          ),
                          SizedBox(height: Responsive.getSize(40)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GiHomeCard(
                                title: "Delegacia",
                                content:
                                    "Encontre a delegacia mais próxima de você.",
                                icon: GiAppAssets.shield,
                                onTap: () {
                                  navigator.goto(GiRoutes.policeStation);
                                },
                              ),

                              SizedBox(width: Responsive.getSize(24)),

                              GiHomeCard(
                                title: "Anjo Guardião",
                                content:
                                    "Adicione pessoas de segurança que serão alertadas.",
                                icon: GiAppAssets.angel,
                                onTap: () {
                                  navigator.goto(GiRoutes.guardian);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.getSize(24)),

                          Container(
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              border: Border.all(color: accentColor, width: 2),

                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(2, -2),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                  color: accentColor.withValues(alpha: 0.3),
                                ),
                                BoxShadow(
                                  offset: Offset(-2, -2),
                                  blurRadius: 6,
                                  spreadRadius: 2,

                                  color: accentColor.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      Responsive.getSize(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sua localização aproximada',
                                          style: BasFontStyle.bodyLargeBoldSec
                                              .copyWith(color: darkGrey),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              BasIcons.pin,
                                              color: grey,
                                              size: Responsive.getSize(16),
                                            ),
                                            Expanded(
                                              child: Text(
                                                controller.place,
                                                style: BasFontStyle.body
                                                    .copyWith(color: grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: Responsive.getSize(16)),
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: Image.asset(
                                    GiAppAssets.map,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Responsive.getSize(24)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
