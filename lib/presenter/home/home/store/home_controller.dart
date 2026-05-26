import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gina/domain/entities/tab_menu.dart';
import 'package:gina/domain/entities/user_entity.dart';

import '../../../../data/emergency/create_emergency_datasource.dart';
import '../../../../theme/icons.dart';

class HomeController extends ChangeNotifier {
  UserEntity? user;
  String place = "Carregando...";
  Position? currentPosition;
  final tabs = [
    TabMenuEntity(name: "Psicólogos", icon: BasIcons.psychology),
    TabMenuEntity(name: "Anjos", icon: BasIcons.angel),
    TabMenuEntity(name: "Apoiadores", icon: BasIcons.sponsors),
    TabMenuEntity(name: "Compartilhar", icon: BasIcons.share),
  ];

  Future<bool> getCurrentAddress() async {
    try {
      //final status = await Permission.location.request();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) {
        // Aqui o iOS não abre mais o pop-up. Você deve avisar a usuária
        // para abrir as configurações.
        return false;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark currentPlace = placemarks[0];

        place =
            "${currentPlace.thoroughfare}, ${currentPlace.subThoroughfare} - ${currentPlace.subLocality}, ${currentPlace.subAdministrativeArea}";
      }
      notifyListeners();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> startEmergency() async {
    final emergencyDatasource = CreateEmergencyDatasource();
    final guardians = user!.myGuardians ?? [];
    await emergencyDatasource(userId: user!.id!, guardians: guardians);
  }

  Future<void> stopEmergency() async {
    final emergencyDatasource = CreateEmergencyDatasource();
    final guardians = user!.myGuardians ?? [];
    emergencyDatasource.stopEmergency(user!.id!, guardians);
  }
}
