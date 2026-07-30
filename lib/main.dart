import 'dart:async';
import 'dart:developer';
import 'dart:io';

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
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 SOLUÇÃO PARA O DUPLICATE APP: Envolver em um bloco try/catch limpo
  // e verificar de forma segura a existência da app padrão.
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
    // Se outra thread inicializar no exato milissegundo, capturamos o erro de duplicidade e reaproveitamos
    if (e.toString().contains('duplicate-app')) {
      Firebase.app();
      print(
        "🔄 Instância duplicada evitada. Firebase reaproveitado com sucesso.",
      );
    } else {
      print("Erro ao inicializar o Firebase: $e");
    }
  }

  // Executa as permissões e serviços
  await _checkPermissions();

  // Executa a configuração de áudio APENAS se for Android (evita crashes futuros no iOS)
  if (Platform.isAndroid) {
    await initializeAndroidAudioSettings();
  }

  await _checkPermissions();

  final routeObserver = RouteStackObserver.instance();

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

Future<void> _checkPermissions() async {
  // <<<<<<< HEAD
  //   // Solicita a permissão padrão de Bluetooth (Válida para iOS e Android antigo)
  //   var status = await Permission.bluetooth.request();
  //   var notifyStatus = await Permission.notification.request();

  //   if (status.isPermanentlyDenied) {
  //     log('Bluetooth Permission disabled');
  //   }

  //   // Permissões específicas do Android 12+ para buscar dispositivos Bluetooth próximos
  //   if (Platform.isAndroid) {
  //     status = await Permission.bluetoothConnect.request();
  //     if (status.isPermanentlyDenied) {
  //       log('Bluetooth Connect Permission disabled');
  //     }
  //   }

  //   // Tratamento da Notificação e ativação do botão na tela de bloqueio
  //   if (!notifyStatus.isPermanentlyDenied && !notifyStatus.isDenied) {
  //     log('Notification Permission granted, initializing service');
  //     await initializeBackgroundService();
  //   } else {
  //     log('Notification Permission disabled');
  // =======
  // Ajuste nas permissões de notificação
  var notifyStatus = await Permission.notification.request();

  // 🔥 RESOLUÇÃO DO CONGELAMENTO (BLUETOOTH):
  // No seu manifesto atual, você removeu a permissão básica BLUETOOTH para Android 12+,
  // mantendo apenas com maxSdkVersion="30". Chamar Permission.bluetooth.request()
  // sem ela no manifesto causou o travamento infinito da Main Thread.
  // Vamos checar o bluetooth apenas se o app possuir as tags ou rodar no fluxo correto.
  if (Platform.isAndroid) {
    // Solicita apenas o connect que está liberado no seu manifesto atual para Android 12+ (como o Xiaomi dela)
    var bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    if (bluetoothConnectStatus.isPermanentlyDenied) {
      log('Bluetooth Connect Permission disabled');
    }
  } else {
    // Fluxo do iOS
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      log('Bluetooth Permission disabled');
    }
  }

  // Inicializa o serviço contínuo de acesso rápido se a notificação for permitida
  if (notifyStatus.isGranted) {
    log('Notification Permission granted, initializing background service');
    await initializeBackgroundService();
  } else {
    log('Notification Permission denied or permanently denied');
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
