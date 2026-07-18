import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'emergency_shortcut_channel',
    'Acesso Rápido de Emergência',
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
      isForegroundMode: true, // Força a execução contínua em segundo plano
      notificationChannelId: 'emergency_shortcut_channel',
      autoStartOnBoot: true,

      // 🔥 DEFINA OS TEXTOS DA NOTIFICAÇÃO DO SEU BOTÃO DIRETO AQUI
      initialNotificationTitle: 'Proteção para você',
      initialNotificationContent:
          '🚨 TOQUE AQUI PARA ABRIR O APP IMEDIATAMENTE',
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

  // 🔥 SOLUÇÃO DEFINITIVA: Satisfez o Android nativo instantaneamente
  if (service is AndroidServiceInstance) {
    // Comunica ao Android nativo nos primeiros milissegundos que este serviço é Foreground
    service.setAsForegroundService();

    // Força a atualização dos textos e garante que os parâmetros de visibilidade fiquem travados
    service.setForegroundNotificationInfo(
      title: "Proteção para você",
      content: "🚨 TOQUE AQUI PARA ABRIR O APP IMEDIATAMENTE",
    );
  }

  // Se você precisar escutar atualizações de localização, banco de dados ou
  // robôs de chamadas em segundo plano daqui para frente, faça abaixo desta linha:
}
