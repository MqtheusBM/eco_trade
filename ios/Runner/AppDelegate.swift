import Flutter
import UIKit
import GoogleMaps // Adicionado o import do Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Adicione a sua chave da API do Google Maps aqui
    GMSServices.provideAPIKey("SUA_CHAVE_API_AQUI")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
