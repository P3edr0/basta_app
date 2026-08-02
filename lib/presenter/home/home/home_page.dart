import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/components/buttons/rounded_button.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/dialogs/info_dialog.dart';
import 'package:gina/components/dialogs/success_dialog.dart';
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
      final navigatorContext = navigatorKey.currentContext;

      guardianTracking.call(
        userId: authController.user!.id!,
        protectedVictimsIds: authController.user?.myGuardians ?? [],

        onEmergencyDetected: (victimId, emergencyId) async {
          if (navigatorContext == null) {
            log("Context = null");
          } else {
            log("Context é diferente de null");
          }
          if (navigatorContext == null) return;
          final guardiansController =
              navigatorContext.read<GuardianController>();
          final emergencyDetailsController =
              navigatorContext.read<EmergencyDetailsController>();

          if (guardiansController.guardianEmergencyActivated) return;
          final guardian = guardiansController.allGuardians.firstWhere(
            (guard) => guard.id == victimId,
          );
          guardiansController.setGuardianEmergencyActivated(true, guardian);

          emergencyDetailsController.setEmergencyData(emergencyId, guardian);
          await Future.delayed(Durations.medium3);

          await EmergencyDialog.show(
            "Atenção",
            "${guardian.name} acionou o botão de emergência!\nAcompanhe a localização dela em tempo real.",
            navigatorContext,
            () {
              emergencyDetailsController.setIsEmergency(
                true,
                EmergencyStatus.active,
              );
              navigator.goto(BasRoutes.emergencyDetails);
            },
          );
        },
      );
      final controller = context.read<HomeController>();
      final haveLocationPermission = await controller.getCurrentAddress();
      if (!haveLocationPermission) {
        ErrorDialog.show(
          context: navigatorContext!,
          title: "Atenção",
          content:
              "Você precisa conceder permissão à localização do seu dispositivo para ter acesso as funcionalidades do Basta.",
        );
      }
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
            child: Consumer2<HomeController, GuardianController>(
              builder: (context, controller, guardianController, child) {
                final bool hasImage = controller.user?.image != null;
                final isOnGuardianEmergency =
                    guardianController.guardianEmergencyActivated;
                final isOnEmergency = controller.emergencyActivated;
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
                          Image.asset(
                            BasAppAssets.logo,
                            height: Responsive.getSize(28),
                          ),
                          SizedBox(width: Responsive.getSize(5)),
                          Text(
                            "BASTA",
                            style: BasFontStyle.h3Bold.copyWith(
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
                              navigator.goto(BasRoutes.updateUser);
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

                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: Responsive.getSize(24),
                    //     vertical: Responsive.getSize(16),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children:
                    //         controller.tabs.map((item) {
                    //           return InkWell(
                    //             onTap:
                    //                 () => InfoDialog.closeAuto(
                    //                   "Em breve...",
                    //                   "Estamos desenvolvendo esta funcionalidade.",
                    //                   context,
                    //                 ),
                    //             child: Column(
                    //               children: [
                    //                 Container(
                    //                   padding: EdgeInsets.all(
                    //                     Responsive.getSize(10),
                    //                   ),
                    //                   decoration: BoxDecoration(
                    //                     color: secondaryColor,

                    //                     shape: BoxShape.circle,
                    //                   ),
                    //                   child: Icon(
                    //                     item.icon,
                    //                     size: Responsive.getSize(24),
                    //                     color: primaryColor,
                    //                   ),
                    //                 ),
                    //                 SizedBox(height: Responsive.getSize(4)),
                    //                 Text(
                    //                   item.name,
                    //                   style: BasFontStyle.smallBold.copyWith(
                    //                     color: secondaryColor,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           );
                    //         }).toList(),
                    //   ),
                    // ),
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

                          // Row(
                          //   children: [
                          //     InkWell(
                          //       child: Row(
                          //         children: [
                          //           Icon(
                          //             Icons.settings,
                          //             color: secondaryColor,
                          //             size: Responsive.getSize(24),
                          //           ),
                          //           SizedBox(width: Responsive.getSize(10)),
                          //           Text(
                          //             "Editar servidor",
                          //             style: BasFontStyle.bodyLargeBold
                          //                 .copyWith(color: lightGrey),
                          //           ),
                          //         ],
                          //       ),
                          //       onTap: () {
                          //         ServerConfigDialog.show(
                          //           participantTokenController:
                          //               controller.participantTokenController,
                          //           saveServerDataCallback: () async {
                          //             await controller.updateVideoConfig();
                          //           },
                          //           roomNameController:
                          //               controller.roomNameController,
                          //           serverUrlController:
                          //               controller.serverUrlController,
                          //           context: context,
                          //         );
                          //       },
                          //     ),
                          //     Spacer(),
                          //     InkWell(
                          //       child: Row(
                          //         children: [
                          //           controller.loadingVideoConfig
                          //               ? SizedBox.square(
                          //                 dimension: Responsive.getSize(20),
                          //                 child: CircularProgressIndicator(
                          //                   color: secondaryColor,
                          //                 ),
                          //               )
                          //               : Icon(
                          //                 Icons.refresh,
                          //                 color: secondaryColor,
                          //                 size: Responsive.getSize(24),
                          //               ),
                          //           SizedBox(width: Responsive.getSize(10)),
                          //           Text(
                          //             "Atualizar",
                          //             style: BasFontStyle.bodyLargeBold
                          //                 .copyWith(color: lightGrey),
                          //           ),
                          //         ],
                          //       ),
                          //       onTap: () async {
                          //         await controller.fetchVideoConfig();
                          //       },
                          //     ),
                          //   ],
                          // ),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () async {
                                // final hasInternet =
                                //     await NetworkService.hasInternet();
                                // if (!hasInternet) {
                                //   InternetDialog.show(
                                //     "Atenção",
                                //     "Você precisa de conexão com a internet para iniciar uma emergência.",
                                //     context,
                                //     () async {
                                //       final testInternetAgain =
                                //           await NetworkService.hasInternet();
                                //       if (testInternetAgain) {
                                //         Navigator.of(context).pop();
                                //       }
                                //     },
                                //   );
                                //   return;
                                // }
                                final haveLocationPermission =
                                    await controller.checkLocationPermission();
                                if (!haveLocationPermission) {
                                  ErrorDialog.show(
                                    context: context,
                                    title: "Atenção",
                                    content:
                                        "Você precisa conceder permissão à localização do seu dispositivo para ter acesso ao botão de emergência.",
                                  );
                                  return;
                                }
                                if (isOnEmergency) {
                                  InfoDialog.closeAuto(
                                    "Atenção",
                                    "Você já está com uma emergência ativa",
                                    context,
                                  );
                                  log("Emergência já ativa");
                                  return;
                                }
                                if (isOnGuardianEmergency) {
                                  InfoDialog.closeAuto(
                                    "Atenção",
                                    "Um de seus anjos já está com uma emergência ativa",
                                    context,
                                  );
                                  log("Emergência já ativa");
                                  return;
                                }
                                /* var audioStatus =
                                    await Permission.microphone.request();
                                var cameraStatus =
                                    await Permission.camera.request();

                                if (audioStatus.isDenied ||
                                    audioStatus.isPermanentlyDenied ||
                                    cameraStatus.isDenied ||
                                    cameraStatus.isPermanentlyDenied) {
                                  InfoDialog.closeAuto(
                                    "Atenção",
                                    "Você precisa conceder permissão para acessar o microfone e a câmera para iniciar uma chamada de emergência.",
                                    context,
                                  );
                                  log("Sem permissão para video Chamadas");
                                  return;
                                }
*/
                                // TODO:REMOVIDO PARA CUSTOMIZAÇÃO DO SERVIDOR"

                                // final serverConfig = controller.videoConfig;

                                // final callData = CallDataEntity(
                                //   serverUrl: serverConfig!.serverUrl!,
                                //   roomName: serverConfig.roomName!,
                                //   token: serverConfig.participantToken!,
                                // );
                                //TODO: CALL COMPONENTS
                                // final callData = await controller.createCall();

                                // final callController =
                                //     context.read<CallController>();
                                // callController.setCall(callData!);
                                controller.setEmergencyActivated(true);
                                await controller.startEmergency();
                                SuccessDialog.show(
                                  "Emergencia ativada",
                                  "Você está sendo monitorada por seus anjos guardiões, eles receberão sua localização em tempo real.",
                                  context,
                                );
                                log("Emergência já ativa");
                                // navigator.goto(BasRoutes.call);

                                return;
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                    isOnEmergency
                                        ? blue.withValues(alpha: 0.2)
                                        : isOnGuardianEmergency
                                        ? mediumDarkBlue.withValues(alpha: 0.2)
                                        : secondaryColor.withValues(alpha: 0.1),
                                radius: Responsive.getSize(120),

                                child: CircleAvatar(
                                  radius: Responsive.getSize(100),
                                  backgroundColor:
                                      isOnEmergency
                                          ? blue.withValues(alpha: 0.3)
                                          : isOnGuardianEmergency
                                          ? mediumDarkBlue.withValues(
                                            alpha: 0.3,
                                          )
                                          : secondaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        isOnEmergency
                                            ? blue
                                            : isOnGuardianEmergency
                                            ? mediumDarkBlue
                                            : secondaryColor,

                                    radius: Responsive.getSize(80),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          isOnEmergency
                                              ? BasAppAssets.emergencyWhite
                                              : BasAppAssets.emergency,
                                        ),
                                        SizedBox(height: Responsive.getSize(8)),

                                        Text(
                                          "EMERGÊNCIA",
                                          style: BasFontStyle.titleBoldSec
                                              .copyWith(
                                                color:
                                                    isOnEmergency ||
                                                            isOnGuardianEmergency
                                                        ? primaryColor
                                                        : primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.getSize(20)),
                          if (isOnEmergency)
                            BasRoundedButton.solid(
                              color: blue,
                              child: Text(
                                "Finalizar Emergência",
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: secondaryColor,
                                ),
                              ),
                              onTap: () {
                                controller.stopEmergency();
                              },
                            ),
                          if (isOnGuardianEmergency)
                            BasRoundedButton.solid(
                              color: mediumDarkBlue,
                              child: Text(
                                "Acompanhar ${guardianController.guardianOnEmergency?.name ?? "emergência"}",
                                style: BasFontStyle.bodyLargeBold.copyWith(
                                  color: primaryColor,
                                ),
                              ),
                              onTap: () {
                                final emergencyDetailsController =
                                    context.read<EmergencyDetailsController>();
                                emergencyDetailsController.setIsEmergency(
                                  true,
                                  EmergencyStatus.active,
                                );
                                navigator.goto(BasRoutes.emergencyDetails);
                              },
                            ),
                          SizedBox(height: Responsive.getSize(40)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GiHomeCard(
                                title: "Delegacia",
                                content:
                                    "Encontre a delegacia mais próxima de você.",
                                icon: BasAppAssets.shield,
                                onTap: () {
                                  navigator.goto(BasRoutes.policeStation);
                                },
                              ),

                              SizedBox(width: Responsive.getSize(24)),

                              GiHomeCard(
                                title: "Anjo Guardião",
                                content:
                                    "Adicione pessoas de segurança que serão alertadas.",
                                icon: BasAppAssets.angel,
                                onTap: () {
                                  navigator.goto(BasRoutes.guardian);
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
                                    BasAppAssets.map,
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
