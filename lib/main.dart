import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      log("🔥 Firebase inicializado com sucesso!");
    } else {
      Firebase.app();
      log("🔄 Instância existente do Firebase reaproveitada.");
    }
  } catch (e) {
    // Se outra thread inicializar no exato milissegundo, capturamos o erro de duplicidade e reaproveitamos
    if (e.toString().contains('duplicate-app')) {
      Firebase.app();
      log(
        "🔄 Instância duplicada evitada. Firebase reaproveitado com sucesso.",
      );
    } else {
      log("Erro ao inicializar o Firebase: $e");
    }
  }

  // Executa as permissões e serviços
  await _checkPermissions();

  // Executa a configuração de áudio APENAS se for Android (evita crashes futuros no iOS)
  if (Platform.isAndroid) {
    await initializeAndroidAudioSettings();
  }

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

@pragma('vm:entry-point')
Future<void> handlerOnBackgroundMessage(RemoteMessage message) async {
  log(message.notification!.title!.toString(), name: 'Notification');
}

Future<void> _checkPermissions() async {
  // 🔥 RESOLUÇÃO DO CONGELAMENTO (BLUETOOTH):
  // No seu manifesto atual, você removeu a permissão básica BLUETOOTH para Android 12+,
  // mantendo apenas com maxSdkVersion="30". Chamar Permission.bluetooth.request()
  // sem ela no manifesto causou o travamento infinito da Main Thread.
  // Vamos checar o bluetooth apenas se o app possuir as tags ou rodar no fluxo correto.
  /*if (Platform.isAndroid) {
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
  }*/

  // Inicializa o serviço contínuo de acesso rápido se a notificação for permitida
  // Ajuste nas permissões de notificação
  bool isGranted = false;

  if (Platform.isIOS) {
    // 💡 NO IOS: Usar a API do FirebaseMessaging com os parâmetros de UI (alert, badge, sound)
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    log(
      '📌 [iOS] Status da permissão de notificação: ${settings.authorizationStatus}',
    );
  } else {
    // 💡 NO ANDROID: Pode continuar usando o permission_handler
    var notifyStatus = await Permission.notification.request();
    isGranted = notifyStatus.isGranted;
  }

  if (isGranted) {
    log('Notification Permission granted');

    final notificationService = FirebaseNotificationService();
    await notificationService.init();
  } else {
    log('Notification Permission denied or permanently denied');
    return;
  }
  if (Platform.isAndroid) {
    log('initializing background service');

    await initializeBackgroundService();
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
