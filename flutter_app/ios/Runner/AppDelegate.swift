import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var exotelSDKChannel:ExotelSDKChannel?
    let CHANNEL_NAME:String = "ios/exotel_sdk"
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
      exotelSDKChannel = ExotelSDKChannel()
      exotelSDKChannel?.registerMethodChannel(channel: channel)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
