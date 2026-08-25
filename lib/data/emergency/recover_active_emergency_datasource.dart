import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class RecoverActiveEmergencyDatasource {
  final FirebaseDatabase _db =
      FirebaseDatabase.instance; // Já configurado corretamente por você!
  static StreamSubscription<Position>? _trackingSubscription;
  static Timer? _timerFallback;
  static DateTime? _lastFirebaseUpload;
  static bool _isEmergencyActive = false;
  static String? _currentEmergencyId;

  Future<void> call({
    required String userId,
    required List<String> guardians,
  }) async {
    DatabaseReference emergencyRef = _db.ref("emergencies/$userId");
    _currentEmergencyId = emergencyRef.push().key;
    _isEmergencyActive = false;

    log("Iniciando rastreamento de emergência para o usuário: $userId");

    final LocationSettings locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      activityType: ActivityType.otherNavigation,
    );

    DatabaseReference locationsRef = _db.ref(
      "emergencies/$userId/$_currentEmergencyId/locations",
    );
    DateTime lastUploadTime = DateTime.now();

    // 2. Inicia a escuta contínua do GPS
    _trackingSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        if (_lastFirebaseUpload != null) {
          final tempoDesdeUltimoEnvio =
              DateTime.now().difference(_lastFirebaseUpload!).inSeconds;

          // REGRA DE OURO: Se foi enviado um ponto há menos de 4 segundos, ignora este disparo!
          if (tempoDesdeUltimoEnvio < 4) {
            log(
              "[Stream] Ignorando ponto (Carro muito rápido ou GPS instável).",
            );
            return;
          }
        }
        // Se a emergência foi parada enquanto a stream processava, ignora o envio
        if (!_isEmergencyActive) return;

        _lastFirebaseUpload = DateTime.now();
        lastUploadTime = DateTime.now();
        await _enviarPontoNoFirebase(locationsRef, position);
      },
      onError: (error) {
        log("Erro na stream de localização: $error");
      },
    );

    // 3. Mecanismo de segurança (Fallback)
    _timerFallback = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // REGRA DE OURO: Se a flag mudou, cancela usando o objeto 'timer' local imediatamente
      if (!_isEmergencyActive) {
        timer.cancel();
        _timerFallback = null;
        log("[Fallback] Timer cancelado de dentro do loop.");
        return;
      }

      final difference = DateTime.now().difference(lastUploadTime).inSeconds;

      if (difference >= 9) {
        try {
          Position? lastPosition = await Geolocator.getLastKnownPosition();

          // Dupla checagem: o 'await' acima pode demorar, confirmamos se ainda está ativo
          if (lastPosition != null && _isEmergencyActive) {
            await _enviarPontoNoFirebase(locationsRef, lastPosition);
            lastUploadTime = DateTime.now();
            log(
              "[Fallback] Usuária parada. Enviando última localização conhecida.",
            );
          }
        } catch (e) {
          log("Erro no fallback de localização: $e");
        }
      }
    });
  }

  Future<void> stopEmergency(
    String userId,
    List<String> guardians, [
    String status = 'closed',
  ]) async {
    try {
      // Cancela a escuta do GPS
      _trackingSubscription?.cancel();
      _timerFallback?.cancel();
      _isEmergencyActive = false;

      if (status != "closed") {
        DatabaseReference emergencyRef = _db.ref(
          "emergencies/$userId/$_currentEmergencyId",
        );
        DatabaseReference locationsRef = _db.ref(
          "emergencies/$userId/$_currentEmergencyId/locations",
        );

        String? newLocationKey = locationsRef.push().key;

        if (newLocationKey != null) {
          final position = await Geolocator.getCurrentPosition();

          await emergencyRef.set({
            "status": status,
            "date": ServerValue.timestamp,
            "guardians": {for (var guardian in guardians) guardian: true},
            "locations": {
              newLocationKey: {
                "latitude": position.latitude,
                "longitude": position.longitude,
                "last_update": ServerValue.timestamp,
                "status": status,
              },
            },
          });
        }
        log("[INICIADO] Estrutura criada para a emergência.");
        return;
      }

      // Atualiza o status no Firebase para os anjos saberem que acabou
      DatabaseReference locationsRef = _db.ref(
        "emergencies/$userId/$_currentEmergencyId/locations",
      );
      DatabaseReference emergencyRef = _db.ref(
        "emergencies/$userId/$_currentEmergencyId",
      );

      String? newLocationKey = locationsRef.push().key;

      if (newLocationKey != null) {
        final position = await Geolocator.getCurrentPosition();

        await locationsRef.child(newLocationKey).set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "last_update": ServerValue.timestamp,
          "status": status,
        });
      }

      await emergencyRef.update({"status": status});

      log("Emergência finalizada!", name: "ENCERRADO");
    } catch (e, stack) {
      log("Erro na stream de localização: $e, stack: $stack");
    }
  }

  Future<void> _enviarPontoNoFirebase(
    DatabaseReference ref,
    Position position,
  ) async {
    String? newLocationKey = ref.push().key;
    if (newLocationKey != null) {
      try {
        await ref.child(newLocationKey).set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "last_update": ServerValue.timestamp,
          "status": "active",
        });
        log(
          "Posição atualizada no Firebase: [${position.latitude}, ${position.longitude}]",
        );
      } catch (e) {
        log("Erro ao enviar ponto para o Firebase: $e");
      }
    }
  }
}
