import 'package:flutter/material.dart';
import 'package:gina/components/dialogs/error_dialog.dart';
import 'package:gina/components/loadings/loading.dart';
import 'package:gina/presenter/police_station/police_station/store/police_station_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/cards/police_station_card.dart';
import '../../../responsiveness/gi_font_style.dart';
import '../../../theme/colors.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../core/widgets/bottom_navigation_bar.dart';

class EmergencyDetailsPage extends StatefulWidget {
  const EmergencyDetailsPage({super.key});

  @override
  State<EmergencyDetailsPage> createState() => _EmergencyDetailsPageState();
}

class _EmergencyDetailsPageState extends State<EmergencyDetailsPage> {
  final navigator = AppNavigator();
  late GoogleMapController mapController;
  final dragController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<PolicyStationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final response = await controller.getUserLocation(context);

      if (!response) {
        ErrorDialog.show(
          title: "Atenção",
          content:
              "Você recusou o acesso a sua localização. Precisamos dela para te mostrar as delegacias próximas!",
          context: context,
        );
      }
    });
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
        child: Consumer<PolicyStationController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return DashPageLoading();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GiAppBar.secondary(
                  title: "Delegacias Próximas",
                  withPadding: true,
                ),
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

                          child: GoogleMap(
                            myLocationButtonEnabled: true,
                            onMapCreated: _onMapCreated,
                            markers: controller.markers,
                            buildingsEnabled: false,
                            myLocationEnabled: true,
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId("rota_emergencia"),
                                color:
                                    primaryColor, // Use a cor do seu app (Basta)
                                width: 5,
                                points: controller.polylineCoordinates,
                              ),
                            },
                            initialCameraPosition: CameraPosition(
                              target: controller.currentPosition!,
                              zoom: 14,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: screenSize.height / 4,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.6, // Altura inicial (30% da tela)
                          minChildSize: 0.3, // Altura mínima (10% da tela)
                          maxChildSize: 0.9, // Altura máxima (90% da tela)
                          controller: dragController,
                          builder: (
                            BuildContext context,
                            ScrollController scrollController,
                          ) {
                            return Container(
                              padding: EdgeInsets.only(
                                top: Responsive.getSize(10),
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
                                itemCount: controller.stations.length,
                                itemBuilder: (context, index) {
                                  final policeStation =
                                      controller.stations[index];
                                  if (index == 0) {
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Unidades mais próximas',
                                              style: BasFontStyle.titleBoldSec
                                                  .copyWith(color: darkGrey),
                                            ),

                                            SizedBox(
                                              width: Responsive.getSize(24),
                                            ),

                                            Text(
                                              '${controller.stations.length} encontradas',
                                              style: BasFontStyle.bodyBold
                                                  .copyWith(color: grey),
                                            ),
                                          ],
                                        ),

                                        PoliceCard(
                                          policeStation: policeStation,
                                          isSelected:
                                              controller.selectedStation ==
                                              index,

                                          onTap: () {
                                            final end = LatLng(
                                              policeStation
                                                  .coordinates
                                                  .latitude,
                                              policeStation
                                                  .coordinates
                                                  .longitude,
                                            );
                                            controller.getPolyline(end: end);
                                            dragController.jumpTo(0.3);
                                            controller.setSelectedStation(
                                              index,
                                            );
                                            mapController.moveCamera(
                                              CameraUpdate.newLatLng(end),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }

                                  return PoliceCard(
                                    policeStation: policeStation,
                                    isSelected:
                                        controller.selectedStation == index,
                                    onTap: () {
                                      final end = LatLng(
                                        policeStation.coordinates.latitude,
                                        policeStation.coordinates.longitude,
                                      );
                                      controller.getPolyline(end: end);
                                      dragController.jumpTo(0.3);
                                      controller.setSelectedStation(index);

                                      mapController.moveCamera(
                                        CameraUpdate.newLatLng(end),
                                      );
                                    },
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
