import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gina/data/emergency/guardian_tracking_datasource.dart';
import 'package:gina/domain/entities/emergency_history_entity.dart';
import 'package:gina/domain/entities/guardian_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/theme/colors.dart';
import 'package:gina/utils/enums/emergency_status.dart';
import 'package:gina/utils/framework/environment.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class EmergencyDetailsController extends ChangeNotifier {
  UserEntity? user;
  String? emergencyId;
  GuardianEntity? currentVictim;
  EmergencyHistoryEntity? currentEmergency;
  LatLng? currentUserPosition;
  List<LatLng> victimPositions = [];
  Marker? marker;
  bool isLoading = true;
  int? selectedStation;
  List<LatLng> polylineCoordinates = [];
  bool isGuardianEmergency = false;
  EmergencyStatus emergencyStatus = EmergencyStatus.closed;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Environment.mapKey);
  Set<Polyline> polylines = {};

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }

  startPage(EmergencyHistoryEntity newEmergency) {
    currentEmergency = newEmergency;
    setIsEmergency(false, EmergencyStatus.closed);
    victimPositions = currentEmergency!.positions;
    currentVictim = currentEmergency?.guardian;
  }

  void setEmergencyData(String newEmergencyId, GuardianEntity guardian) {
    setCurrentGuardian(guardian);
    currentEmergency = null;
    victimPositions = [];
    emergencyId = newEmergencyId;
    notifyListeners();
  }

  setCurrentGuardian(GuardianEntity? newGuardian) {
    currentVictim = newGuardian;
    notifyListeners();
  }

  setIsEmergency(bool newEmergency, EmergencyStatus newStatus) {
    isGuardianEmergency = newEmergency;
    emergencyStatus = newStatus;

    notifyListeners();
  }

  Future<bool> startListenVictimPositions(Function() onClosedEmergency) async {
    await getUserLocation();

    await _fetchVictimPositions(onClosedEmergency);
    setIsLoading(false);
    return true;
  }

  Future<bool> startConfigHistoricalVictimPositions() async {
    await getUserLocation();

    await _configHistoricalVictimPositions();
    setIsLoading(false);
    return true;
  }

  Future<Position?> getUserLocation() async {
    setIsLoading(true);
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) {
      // Aqui o iOS não abre mais o pop-up. Você deve avisar a usuária
      // para abrir as configurações.
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentUserPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
    return position;
  }

  Future<void> _fetchVictimPositions(Function() onClosedEmergency) async {
    // Carrega o ícone personalizado da internet uma única vez
    final pin = await _loadCustomMarker(currentVictim!.image!);

    GuardianTrackingDataSource().listenToVictimGps(
      victimId: currentVictim!.id!,
      emergencyId: emergencyId!,

      onLocationUpdated: (latitude, longitude) {
        log("Localização atualizada: lat=$latitude, lng=$longitude");

        // 2. Adiciona o novo ponto geográfico real à lista histórica
        victimPositions.add(LatLng(latitude, longitude));

        // 3. Atualiza o marcador sempre para a última posição da lista
        marker = Marker(
          visible: true,
          markerId: MarkerId(currentVictim!.id!),
          position: victimPositions.last,
          consumeTapEvents: false,
          icon: pin,
        );

        // 4. Monta a Polyline ligando TODOS os pontos acumulados até agora
        if (victimPositions.length > 1) {
          polylines = {
            Polyline(
              polylineId: const PolylineId("trajeto_real_vitima"),
              points: victimPositions, // Passa a lista completa
              color: primaryColor, // Cor de alerta
              width: 6, // Espessura da linha
              jointType: JointType.round, // Curvas suaves nas esquinas/muros
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          };
        }

        // 5. Avisa a tela para se reconstruir com o novo ponto e a nova linha
        notifyListeners();
      },
      onEmergencyClosed: onClosedEmergency,
    );
  }

  Future<void> _configHistoricalVictimPositions() async {
    // Carrega o ícone personalizado da internet uma única vez
    final pin = await _loadCustomMarker(currentVictim!.image!);

    // 3. Atualiza o marcador sempre para a última posição da lista
    marker = Marker(
      visible: true,
      markerId: MarkerId(currentVictim!.id!),
      position: victimPositions.last,
      consumeTapEvents: false,
      icon: pin,
    );

    // 4. Monta a Polyline ligando TODOS os pontos acumulados até agora
    if (victimPositions.length > 1) {
      polylines = {
        Polyline(
          polylineId: const PolylineId("trajeto_real_vitima"),
          points: victimPositions, // Passa a lista completa
          color: primaryColor, // Cor de alerta
          width: 6, // Espessura da linha
          jointType: JointType.round, // Curvas suaves nas esquinas/muros
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      };
    }

    // 5. Avisa a tela para se reconstruir com o novo ponto e a nova linha
    notifyListeners();
  }

  Future<BitmapDescriptor> _loadCustomMarker(String imageUrl) async {
    try {
      // 1. Baixa os bytes da imagem da URL
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) throw Exception("Erro ao baixar imagem");

      final Uint8List imageBytes = response.bodyBytes;

      // 2. Instancia o decodificador de imagem do dart:ui
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(
        imageBytes,
        (ui.Image img) => completer.complete(img),
      );
      final ui.Image image = await completer.future;

      // 3. Define o tamanho que o marcador terá no mapa (ex: 120x120 pixels)
      const int targetWidth = 30;
      const int targetHeight = 30;

      // 4. Cria um canvas para desenhar a imagem redimensionada
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;

      // --- OPCIONAL: Cortar a imagem em círculo (Estilo Redes Sociais) ---
      final double radius = targetWidth / 2;
      final Path clipPath =
          Path()..addOval(
            Rect.fromLTRB(
              0,
              0,
              targetWidth.toDouble(),
              targetHeight.toDouble(),
            ),
          );
      canvas.clipPath(clipPath);
      // ------------------------------------------------------------------

      // Desenha a imagem dentro do tamanho estipulado
      canvas.drawImageRect(
        image,
        Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTRB(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint,
      );

      // 5. Converte o canvas de volta para bytes
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image resizedImage = await picture.toImage(
        targetWidth,
        targetHeight,
      );
      final ByteData? byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List resizedBytes = byteData!.buffer.asUint8List();

      // 6. Retorna o BitmapDescriptor pronto para o Google Maps
      return BitmapDescriptor.bytes(resizedBytes);
    } catch (e) {
      // Fallback: Se a internet falhar ou a URL quebrar, retorna um marcador padrão do Google
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void getPolyline({required LatLng end}) async {
    final origin = victimPositions.first;
    final destiny = victimPositions.last;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destiny.latitude, destiny.longitude),
        mode: TravelMode.driving,
      ),
    );
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    notifyListeners();
  }
}
