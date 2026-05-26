import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

class GuardianTrackingDataSource {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Lista para guardar os listeners de cada vítima que este anjo protege
  final List<StreamSubscription<DatabaseEvent>> _activeRadarSubscriptions = [];
  StreamSubscription<DatabaseEvent>? _gpsTrackingSubscription;

  /// O RADAR CORRIGIDO: Escuta as emergências apenas das vítimas protegidas por este anjo
  void call({
    required List<String>
    protectedVictimsIds, // Lista de IDs das mulheres que este anjo protege
    required String userId,
    required Function(String victimId, String emergencyId) onEmergencyDetected,
  }) {
    // 1. Limpa qualquer radar ligado anteriormente
    stopAllRadarListeners();

    log(
      "Iniciando radar para ${protectedVictimsIds.length} vítimas protegidas...",
    );

    // 2. Criamos um listener direto para o nó de cada vítima protegida
    for (String victimId in protectedVictimsIds) {
      // Aponta direto para o nó de emergências daquela vítima específica
      DatabaseReference victimEmergenciesRef = _db.ref("emergencies/$victimId");

      var subscription = victimEmergenciesRef.onValue.listen((
        DatabaseEvent event,
      ) {
        final snapshot = event.snapshot;
        if (snapshot.value == null) return;

        Map<dynamic, dynamic> emergencies =
            snapshot.value as Map<dynamic, dynamic>;

        // Varre as emergências desta vítima específica
        emergencies.forEach((emergencyId, data) {
          log("Radar checando emergência $emergencyId da vítima $victimId...");
          if (data is Map) {
            String status = data['status'] ?? '';
            Map<dynamic, dynamic>? guardians = Map<dynamic, dynamic>.from(
              data['guardians'] ?? {},
            );

            // Verificação cirúrgica na sua estrutura:
            // O status é ativo E este anjo específico está na lista daquela emergência?
            if (status == 'active' && guardians[userId] == true) {
              log(
                "⚠️ EMERGÊNCIA DETECTADA! Vítima: $victimId | Ocorrência: $emergencyId",
              );

              // Dispara o alerta na tela do anjo
              onEmergencyDetected(victimId.toString(), emergencyId.toString());
            }
          }
        });
      }, onError: (error) => log("Erro no radar da vítima $victimId: $error"));

      // Guarda a assinatura para poder cancelar depois
      _activeRadarSubscriptions.add(subscription);
    }
  }

  /// Limpa apenas os ouvintes do Radar
  void stopAllRadarListeners() {
    for (var sub in _activeRadarSubscriptions) {
      sub.cancel();
    }
    _activeRadarSubscriptions.clear();
    log("Radar dos anjos desligado.");
  }

  /// O restante da função de rastreamento do GPS (listenToVictimGps) continua
  /// exatamente igual à anterior, pois ela já recebia o 'victimId' e o 'emergencyId'
  /// diretos e já apontava para o caminho correto!

  void listenToVictimGps({
    required String victimId,
    required String emergencyId,
    required Function(double lat, double lng) onLocationUpdated,
    required Function() onEmergencyClosed,
  }) {
    // Limpa tracking anterior
    _gpsTrackingSubscription?.cancel();

    DatabaseReference emergencyRef = _db.ref(
      "emergencies/$victimId/$emergencyId",
    );

    log(
      "Iniciando rastreamento da emergência $emergencyId da vítima $victimId",
    );

    _gpsTrackingSubscription = emergencyRef.onValue.listen((
      DatabaseEvent event,
    ) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return;

      Map<dynamic, dynamic> emergencyData =
          snapshot.value as Map<dynamic, dynamic>;

      // A) Checa se a vítima encerrou a emergência
      if (emergencyData['status'] == 'closed') {
        log("A emergência foi encerrada pela vítima.");
        onEmergencyClosed();
        stopGpsTracking();
        return;
      }

      // B) Captura os pontos de GPS dentro do nó 'locations'
      if (emergencyData['locations'] != null) {
        Map<dynamic, dynamic> locations =
            emergencyData['locations'] as Map<dynamic, dynamic>;

        // Como queremos o ponto MAIS RECENTE, ordenamos pela chave ou pelo timestamp interno
        // Em mapas Dart, podemos transformar em lista e pegar o último adicionado
        var sortedKeys = locations.keys.toList()..sort();
        if (sortedKeys.isNotEmpty) {
          var lastLocationKey = sortedKeys.last;
          var lastLocation = locations[lastLocationKey];

          double lat = double.parse(lastLocation['latitude'].toString());
          double lng = double.parse(lastLocation['longitude'].toString());

          // Envia as coordenadas em tempo real para o mapa atualizar o marcador (Marker)
          onLocationUpdated(lat, lng);
        }
      }
    });
  }

  /// Limpeza de memória
  void stopGpsTracking() {
    _gpsTrackingSubscription?.cancel();
    _gpsTrackingSubscription = null;
    log("Rastreamento de GPS do anjo encerrado.");
  }

  void stopAllListeners() {
    //_radarSubscription?.cancel();
    _gpsTrackingSubscription?.cancel();
    log("Todos os listeners do anjo foram desligados.");
  }
}
