import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class FetchEmergenciesDatasource {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  static StreamSubscription<Position>? _trackingSubscription;
  static Timer? _timerFallback;
  static DateTime? _lastFirebaseUpload;
  static bool _isEmergencyActive = false;

  Future<void> call({required String userId}) async {
    await stopEmergency(userId, "active");
    _isEmergencyActive = true;

    log("Iniciando rastreamento de emergência para o usuário: $userId");

    DatabaseReference ref = _db.ref("emergencies/$userId/locations");
    //final response = await ref.get();

    final DataSnapshot queryEmergenciasDoAnjo =
        await FirebaseDatabase.instance
            .ref("emergencies")
            // Filtra buscando se o ID deste anjo específico está dentro do nó 'active_angels'
            .orderByChild("active_angels/$userId")
            .get();
  }

  Future<void> stopEmergency(String userId, [String status = 'closed']) async {
    try {
      // Cancela a escuta do GPS
      _trackingSubscription?.cancel();
      _timerFallback?.cancel();
      _isEmergencyActive = false;

      // Atualiza o status no Firebase para os anjos saberem que acabou
      DatabaseReference ref = _db.ref("emergencies/$userId/locations");

      String? newLocationKey = ref.push().key;

      if (newLocationKey != null) {
        final position = await Geolocator.getCurrentPosition();

        await ref.child(newLocationKey).set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "last_update": ServerValue.timestamp,
          "status": status,
        });

        log("Emergência finalizada!", name: "ENCERRADO");
      }
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
