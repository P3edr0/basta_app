import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gina/domain/entities/tab_menu.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../theme/icons.dart';

class HomeController extends ChangeNotifier {
  UserEntity? user;
  String place = "Carregando...";
  final tabs = [
    TabMenuEntity(name: "Psicólogos", icon: BasIcons.psychology),
    TabMenuEntity(name: "Anjos", icon: BasIcons.angel),
    TabMenuEntity(name: "Apoiadores", icon: BasIcons.sponsors),
    TabMenuEntity(name: "Compartilhar", icon: BasIcons.share),
  ];

  Future<bool> getCurrentAddress() async {
    try {
      final status = await Permission.location.request();

      if (!status.isGranted && !status.isProvisional) {
        return false;
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
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
}
