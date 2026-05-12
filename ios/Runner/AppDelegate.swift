import UIKit
import Flutter
import GoogleMaps 


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 2. Adicione sua chave de API aqui
    GMSServices.provideAPIKey("AIzaSyCHU69xw5O9j3-V7XKzyA6gIMVrYwZcqwU") 
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}