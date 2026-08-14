import 'package:flutter/material.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/dialogs/success_dialog.dart';
import 'package:gina/components/loadings/loading.dart';
import 'package:gina/presenter/guardian/emergency_details/store/emergency_details_controller.dart';
import 'package:gina/utils/enums/emergency_status.dart';
import 'package:gina/utils/formatters/date_formatter.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../responsiveness/gi_font_style.dart';
import '../../../theme/colors.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../core/widgets/bottom_navigation_bar.dart';
import '../store/guardian_controller.dart';

class EmergencyDetailsPage extends StatefulWidget {
  const EmergencyDetailsPage({super.key});

  @override
  State<EmergencyDetailsPage> createState() => _EmergencyDetailsPageState();
}

class _EmergencyDetailsPageState extends State<EmergencyDetailsPage> {
  final _navigator = AppNavigator();
  late GoogleMapController mapController;
  final dragController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<EmergencyDetailsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool response = false;
      if (controller.isGuardianEmergency) {
        response = await controller.startListenVictimPositions(
          onClosedEmergency,
        );
      } else {
        response = await controller.startConfigHistoricalVictimPositions();
      }
      if (!response) {
        ErrorDialog.show(
          title: "Atenção",
          content:
              "Não foi possível mostrar as posições da vítima! Tente novamente mais tarde!",
          context: context,
        );
      }
    });
  }

  void onClosedEmergency() async {
    final controller = context.read<EmergencyDetailsController>();

    await SuccessDialog.show(
      "Encerrado",
      "A vítima encerrou a emergência! Entre em contato com ela para garantir que esteja bem!",
      context,
    );
    final guardiansController = context.read<GuardianController>();
    controller.setIsEmergency(false, EmergencyStatus.closedNow);
    guardiansController.setGuardianEmergencyActivated(false, null);
    if (controller.victimPositions.isEmpty) {
      await _navigator.goto(BasRoutes.home, clearStack: true);
    }
  }

  _onMapCreated(GoogleMapController newMapController) {
    mapController = newMapController;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BasBottomNavigationBar(),
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Consumer<EmergencyDetailsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return DashPageLoading();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasAppBar.secondary(title: "Emergências", withPadding: true),
                SizedBox(height: Responsive.getSize(10)),

                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: primaryColor,

                          child:
                              controller.victimPositions.isEmpty
                                  ? DashPageLoading.secondary(
                                    title:
                                        "Fazendo mapeamento da posição da vítima...",
                                  )
                                  : GoogleMap(
                                    myLocationButtonEnabled: true,
                                    onMapCreated: _onMapCreated,
                                    markers:
                                        controller.marker != null
                                            ? {controller.marker!}
                                            : {},
                                    buildingsEnabled: false,
                                    myLocationEnabled: true,
                                    polylines: controller.polylines,
                                    initialCameraPosition: CameraPosition(
                                      target: controller.victimPositions.last,
                                      zoom: 14,
                                    ),
                                  ),
                        ),
                      ),

                      if (controller.victimPositions.isNotEmpty)
                        Positioned(
                          top: screenSize.height / 2,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: DraggableScrollableSheet(
                            initialChildSize:
                                0.6, // Altura inicial (30% da tela)
                            minChildSize: 0.3, // Altura mínima (10% da tela)
                            maxChildSize: 0.9, // Altura máxima (90% da tela)
                            controller: dragController,
                            builder: (
                              BuildContext context,
                              ScrollController scrollController,
                            ) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.getSize(10),
                                  horizontal: Responsive.getSize(10),
                                ),
                                decoration: BoxDecoration(
                                  color: secondaryColor,

                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(2, -2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: darkGrey.withValues(alpha: 0.3),
                                    ),
                                    BoxShadow(
                                      offset: Offset(-2, -2),
                                      blurRadius: 6,
                                      spreadRadius: 2,

                                      color: darkGrey.withValues(alpha: 0.3),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  controller: scrollController,
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    final date =
                                        controller.currentEmergency?.date ??
                                        DateTime.now();
                                    return Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,

                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: Responsive.getSize(6),
                                            ),
                                            width: Responsive.getSize(80),
                                            height: Responsive.getSize(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: Responsive.getSize(40),
                                              backgroundColor: grey,
                                              child:
                                                  controller
                                                              .currentVictim!
                                                              .image !=
                                                          null
                                                      ? ClipOval(
                                                        child: Image.network(
                                                          controller
                                                              .currentVictim!
                                                              .image!,
                                                          width:
                                                              Responsive.getSize(
                                                                80,
                                                              ),
                                                          height:
                                                              Responsive.getSize(
                                                                80,
                                                              ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                      : Icon(
                                                        Icons.person,
                                                        size:
                                                            Responsive.getSize(
                                                              40,
                                                            ),
                                                        color: Colors.white,
                                                      ),
                                            ),

                                            SizedBox(
                                              width: Responsive.getSize(24),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "Dados da emergência",
                                                  style: BasFontStyle
                                                      .bodyLargeBold
                                                      .copyWith(
                                                        color: primaryColor,
                                                      ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      controller
                                                          .currentVictim!
                                                          .name,
                                                      style: BasFontStyle.h4Bold
                                                          .copyWith(
                                                            color: darkGrey,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                controller
                                                        .emergencyStatus
                                                        .isActive
                                                    ? Row(
                                                      children: [
                                                        Text(
                                                          'Tempo real',
                                                          style: BasFontStyle
                                                              .bodyBold
                                                              .copyWith(
                                                                color: grey,
                                                              ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                            left:
                                                                Responsive.getSize(
                                                                  4,
                                                                ),
                                                          ),
                                                          width:
                                                              Responsive.getSize(
                                                                8,
                                                              ),
                                                          height:
                                                              Responsive.getSize(
                                                                8,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                color: success,
                                                              ),
                                                        ),
                                                      ],
                                                    )
                                                    : Text(
                                                      BasDateFormat.notificationFormat(
                                                        (date),
                                                      ),
                                                      style: BasFontStyle
                                                          .bodyBoldSec
                                                          .copyWith(
                                                            color: darkGrey,
                                                          ),
                                                    ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
