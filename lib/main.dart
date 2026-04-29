import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'domain/providers.dart';
import 'firebase_options.dart';
import 'theme/custom_themes/theme.dart';
import 'utils/routes/app_pages.dart';
import 'utils/routes/route_observer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // 1. INICIALIZAÇÕES DENTRO DA ZONA
  WidgetsFlutterBinding.ensureInitialized();

  // 2. CONFIGURAÇÕES DO FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
