import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  // 1. Checagem rápida pontual (para usar no clique de um botão, por exemplo)
  static Future<bool> hasInternet() async {
    // Primeiro verifica se o aparelho tem alguma interface de rede ligada
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false; // Sem Wi-Fi nem Dados Móveis
    }

    // Se tem rede, faz um ping real para confirmar que a internet responde
    return await InternetConnection().hasInternetAccess;
  }

  // 2. Stream em tempo real (para monitorar enquanto o app está aberto)
  static StreamSubscription<InternetStatus> listenToConnection(
    Function(bool isConnected) onStatusChanged,
  ) {
    return InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          onStatusChanged(true);
          break;
        case InternetStatus.disconnected:
          onStatusChanged(false);
          break;
      }
    });
  }
}
