import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseNotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String? token;

  Future<void> createLocalNotificationChannel() async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications',
          importance: Importance.high,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> createEmergencyNotificationChannel() async {
    const AndroidNotificationChannel emergencyNotificationChannel =
        AndroidNotificationChannel(
          'emergency_channel_v3',
          'Emergency Notifications',
          description: 'This channel is used for important notifications',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('alert'),
          playSound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(emergencyNotificationChannel);
  }

  Future<void> init() async {
    final permission = await _firebaseMessaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      throw Exception("O usuário recusou receber notificações.");
    }

    await getToken();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(message.notification!.title!.toString(), name: 'Notification');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      // 1. Extrai a imagem do Flutter para o armazenamento físico do celular
      // 👈 CORREÇÃO: Tiramos o "if (Platform.isIOS)" para que o Android também gere a imagem
      String imagePath = await _saveLocalImage(
        'assets/images/emergency_notification.jpg', // O caminho no seu pubspec.yaml
        'alert.jpg',
      );

      if (notification != null) {
        // 💡 Lê o tipo que veio lá da Cloud Function (data.type)
        final String? notificationType = message.data['type'];

        // Verifica se é uma emergência
        final bool isEmergency = notificationType == 'EMERGENCY_ALERT';

        AndroidNotificationDetails? androidPlatformChannelSpecifics;
        if (Platform.isAndroid) {
          androidPlatformChannelSpecifics = AndroidNotificationDetails(
            isEmergency ? 'emergency_channel_v3' : 'high_importance_channel',
            isEmergency
                ? 'Emergency Notifications'
                : 'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.max,
            priority: Priority.high,

            // 👈 CORREÇÃO 1: Removido o '@drawable/'. O correto é apenas o nome do arquivo.
            icon: 'ic_notification',
            playSound: true,

            sound:
                isEmergency
                    ? const RawResourceAndroidNotificationSound('alert')
                    : null,
            styleInformation:
                isEmergency
                    ? BigPictureStyleInformation(
                      // 👈 CORREÇÃO 2: Usa a imagem que acabamos de extrair do Flutter (igual no iOS)
                      FilePathAndroidBitmap(imagePath),
                      largeIcon: const DrawableResourceAndroidBitmap(
                        'ic_notification',
                      ),
                      contentTitle: message.notification?.title,
                      summaryText: message.notification?.body,
                    )
                    : null,
          );
        }

        DarwinNotificationDetails? iosPlatformChannelSpecifics;
        String? iosSound = message.notification?.apple?.sound?.name;
        if (Platform.isIOS) {
          iosPlatformChannelSpecifics = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: iosSound,
            interruptionLevel:
                isEmergency
                    ? InterruptionLevel.timeSensitive
                    : InterruptionLevel.active,
            attachments:
                isEmergency ? [DarwinNotificationAttachment(imagePath)] : null,
          );
        }

        // Exibe a notificação local respeitando o canal adequado
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iosPlatformChannelSpecifics,
          ),
        );
      }
    });

    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    final DarwinInitializationSettings
    darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      //   // Lógica opcional quando uma notificação local é recebida no iOS
      //   log('Notificação local recebida no iOS: $title', name: 'NotificationService');
      // },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: darwinInitializationSettings,
        );
    // NOVO: Configuração para iOS
    // Apenas solicita permissão para exibir alertas, sons e badges.

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,

      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    await createLocalNotificationChannel();
    await createEmergencyNotificationChannel();
  }

  Future<String?> getToken() async {
    // final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      token = await _firebaseMessaging.getToken();
    } catch (e) {
      token = "notification_token";
    }
    log(token.toString(), name: 'Token');
    debugPrint(token.toString());
    return token;
  }

  static void _onNotificationTap(NotificationResponse details) {
    log('Notificação tocada: ${details.payload}', name: 'NotificationService');
    // Aqui você pode navegar para uma tela específica
  }
}

// Função para extrair a imagem do Flutter e salvar na memória física do iPhone
Future<String> _saveLocalImage(String assetPath, String nomeArquivo) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDirectory = await getTemporaryDirectory();
  final file = File('${tempDirectory.path}/$nomeArquivo');
  await file.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );
  return file.path;
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // 👈 AQUI: Defina explicitamente o ícone nativo padrão do seu plugin local
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'emergency_shortcut_channel_v4',
    'Acesso Rápido de Emergência',
    description: 'Mantém o botão de acesso rápido ativo na tela de bloqueio.',
    importance: Importance.max,
  );

  // Cria o canal no Android nativo
  final androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart:
          false, // 👈 MUDOU PARA FALSE: Vamos controlar o início manualmente sem conflito
      isForegroundMode: true,
      notificationChannelId: 'emergency_shortcut_channel_v4',
      autoStartOnBoot: true,
      initialNotificationTitle: 'Proteção para você',
      initialNotificationContent:
          '🚨 TOQUE AQUI PARA ABRIR O APP IMEDIATAMENTE',
      foregroundServiceNotificationId: 889,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  // Inicia o serviço manualmente após o configure ter terminado totalmente
  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // 👈 Sinais essenciais para o Android nativo não derrubar o serviço nos primeiros ms
    await service.setAsForegroundService();

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Define as informações de exibição da notificação persistente
    service.setForegroundNotificationInfo(
      title: "Proteção para você",
      content: "🚨 TOQUE AQUI PARA ABRIR O APP IMEDIATAMENTE",
    );
  }
}
