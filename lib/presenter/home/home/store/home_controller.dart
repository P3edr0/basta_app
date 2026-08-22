import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gina/data/call/create_call_datasource.dart';
import 'package:gina/data/server/fetch_video_config_datasource.dart';
import 'package:gina/domain/entities/call_data_entity.dart';
import 'package:gina/domain/entities/tab_menu.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/domain/entities/video_config_entity.dart';

import '../../../../data/emergency/create_emergency_datasource.dart';
import '../../../../data/server/update_video_config_datasource.dart';
import '../../../../theme/icons.dart';

class HomeController extends ChangeNotifier {
  UserEntity? user;
  CallDataEntity? call;
  VideoConfigEntity? videoConfig;
  bool loadingVideoConfig = false;
  bool emergencyActivated = false;
  final participantTokenController = TextEditingController();
  final roomNameController = TextEditingController();
  final serverUrlController = TextEditingController();
  String place = "Carregando...";
  Position? currentPosition;
  final tabs = [
    TabMenuEntity(name: "Psicólogos", icon: BasIcons.psychology),
    TabMenuEntity(name: "Anjos", icon: BasIcons.angel),
    TabMenuEntity(name: "Apoiadores", icon: BasIcons.sponsors),
    TabMenuEntity(name: "Compartilhar", icon: BasIcons.share),
  ];

  void setLoadingVideoConfig() {
    loadingVideoConfig = !loadingVideoConfig;
    notifyListeners();
  }

  Future<bool> getCurrentAddress() async {
    final hasPermission = await getLocationPermission();
    if (!hasPermission) return false;
    try {
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
        String sublocality = currentPlace.subLocality ?? '';
        if (sublocality.isNotEmpty) {
          sublocality = '- $sublocality';
        }
        place =
            "${currentPlace.thoroughfare}, ${currentPlace.subThoroughfare}$sublocality, ${currentPlace.subAdministrativeArea}";
      }
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("Erro: $e Stack: $stack");
      return false;
    }
  }

  Future<bool> getLocationPermission() async {
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
    return true;
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      // Aqui o iOS não abre mais o pop-up. Você deve avisar a usuária
      // para abrir as configurações.
      return false;
    }
    return true;
  }

  Future<CallDataEntity?> createCall() async {
    final createCallDatasource = CreateCallDatasource();
    final response = await createCallDatasource(user!.id!);

    return response.fold(
      (l) {
        return null;
      },
      (newCall) {
        call = newCall;
        return newCall;
      },
    );
  }

  Future<VideoConfigEntity?> fetchVideoConfig() async {
    setLoadingVideoConfig();
    final fetchVideoConfig = FetchVideoConfigDatasource();
    final response = await fetchVideoConfig();

    return response.fold(
      (l) {
        setLoadingVideoConfig();
        return null;
      },
      (newVideoConfig) {
        videoConfig = newVideoConfig;

        participantTokenController.text = videoConfig!.participantToken ?? "";
        roomNameController.text = videoConfig!.roomName ?? "";
        serverUrlController.text = videoConfig!.serverUrl ?? "";
        setLoadingVideoConfig();

        return newVideoConfig;
      },
    );
  }

  Future<bool> updateVideoConfig() async {
    final newVideoConfig = VideoConfigEntity(
      id: videoConfig?.id,
      participantToken: participantTokenController.text,
      roomName: roomNameController.text,
      serverUrl: serverUrlController.text,
    );
    final fetchVideoConfig = UpdateVideoConfigDatasource();
    final response = await fetchVideoConfig(newVideoConfig);

    return response.fold(
      (l) {
        return false;
      },
      (success) {
        videoConfig = newVideoConfig;

        notifyListeners();
        return success;
      },
    );
  }

  Future<void> startEmergency() async {
    final emergencyDatasource = CreateEmergencyDatasource();
    final guardians = user!.myGuardians ?? [];
    await emergencyDatasource(userId: user!.id!, guardians: guardians);
  }

  void setEmergencyActivated(bool value) {
    emergencyActivated = value;
    notifyListeners();
  }

  Future<void> stopEmergency() async {
    setEmergencyActivated(false);
    final emergencyDatasource = CreateEmergencyDatasource();
    final guardians = user!.myGuardians ?? [];
    emergencyDatasource.stopEmergency(user!.id!, guardians);
  }
}
