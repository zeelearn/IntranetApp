import UIKit
import Flutter
import awesome_notifications
import flutter_downloader
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

//    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "your.custom.task.identifier"
GMSServices.provideAPIKey("AIzaSyA20o2gNqJ70-_SuHdcpNgIvKlHUhOlG-A")
    GeneratedPluginRegistrant.register(with: self)
      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
              SwiftAwesomeNotificationsPlugin.register(
                with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
          }
    

    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
                    SwiftAwesomeNotificationsPlugin.register(
                      with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)}
 FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
