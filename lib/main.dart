import 'dart:async';
import 'dart:developer';
import 'dart:io'; // IMPORTANTE: Adicionado para verificar a plataforma (Platform.isAndroid)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'domain/providers.dart';
import 'firebase_options.dart';
import 'services/notifications/notification_service.dart';
import 'theme/custom_themes/theme.dart';
import 'utils/routes/app_pages.dart';
import 'utils/routes/route_observer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // 1. INICIALIZAÇÕES DENTRO DA ZONA
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("🔥 Firebase inicializado com sucesso!");
    } else {
      Firebase.app();
      print("🔄 Instância existente do Firebase reaproveitada.");
    }
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
  }

  await checkPermissions();

  // 4. INICIALIZA CONFIGURAÇÕES DE ÁUDIO APENAS SE FOR ANDROID
  if (Platform.isAndroid) {
    await initializeAndroidAudioSettings();
  }

  // 5. OBSERVER DE ROTA
  final routeObserver = RouteStackObserver.instance();

  // 6. RUN APP
  runApp(
    MultiProvider(
      providers: Providers.providers,
      child: MaterialApp(
        title: 'BASTA',
        navigatorKey: navigatorKey,
        onGenerateRoute: AppPages.onGenerateRoute,
        navigatorObservers: [routeObserver],
        theme: TneAppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

Future<void> checkPermissions() async {
  // Solicita a permissão padrão de Bluetooth (Válida para iOS e Android antigo)
  var status = await Permission.bluetooth.request();
  var notifyStatus = await Permission.notification.request();

  if (status.isPermanentlyDenied) {
    log('Bluetooth Permission disabled');
  }

  // Permissões específicas do Android 12+ para buscar dispositivos Bluetooth próximos
  if (Platform.isAndroid) {
    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      log('Bluetooth Connect Permission disabled');
    }
  }

  // Tratamento da Notificação e ativação do botão na tela de bloqueio
  if (!notifyStatus.isPermanentlyDenied && !notifyStatus.isDenied) {
    log('Notification Permission granted, initializing service');
    await initializeBackgroundService();
  } else {
    log('Notification Permission disabled');
  }
}

Future<void> initializeAndroidAudioSettings() async {
  await webrtc.WebRTC.initialize(
    options: {
      'androidAudioConfiguration':
          webrtc.AndroidAudioConfiguration.media.toMap(),
    },
  );
  webrtc.Helper.setAndroidAudioConfiguration(
    webrtc.AndroidAudioConfiguration.media,
  );
}
