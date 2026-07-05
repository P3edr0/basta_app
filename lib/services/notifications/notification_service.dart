import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Configuração do canal de notificação local
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'emergency_shortcut_channel', // ID do canal
    'Acesso Rápido de Emergência', // Nome visível
    description: 'Mantém o botão de acesso rápido ativo na tela de bloqueio.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'emergency_shortcut_channel',
      initialNotificationTitle: 'Proteção Ativa',
      initialNotificationContent: 'Toque para abrir o app instantaneamente',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Se for Android, exibe a notificação FIXA apenas UMA VEZ no início
  if (service is AndroidServiceInstance) {
    flutterLocalNotificationsPlugin.show(
      888,
      'Proteção para você',
      '🚨 TOQUE AQUI PARA ABRIR O APP IMEDIATAMENTE',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'emergency_shortcut_channel',
          'Acesso Rápido de Emergência',
          ongoing: true, // Garante que NUNCA seja apagada deslizando
          importance: Importance.max,
          priority: Priority.high,
          visibility:
              NotificationVisibility.public, // Visível na tela de bloqueio
          icon: 'ic_notification', // Seu ícone customizado
        ),
      ),
    );
  }
}
