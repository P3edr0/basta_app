import UIKit
import Flutter
import GoogleMaps 
import UserNotifications


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 2. Adicione sua chave de API aqui
    GMSServices.provideAPIKey("AIzaSyCHU69xw5O9j3-V7XKzyA6gIMVrYwZcqwU") 
      // Registra o delegate nativo de notificações para o iOS
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}