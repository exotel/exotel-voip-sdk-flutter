import Flutter
import UIKit
import ExotelVoice

public class ExotelPlugin: NSObject, FlutterPlugin {
    private let TAG = "ExotelPlugin"
    var methodDelegate: ExotelSDKChannel?
    public static var methodChannel: FlutterMethodChannel!

    // Registering the plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "exotel/ios_plugin", binaryMessenger: registrar.messenger())
        
        let instance = ExotelPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        instance.methodDelegate = ExotelSDKChannel() // Initialize your delegate
        methodChannel = channel
        
        let sdkChannel = ExotelSDKChannel()
        sdkChannel.setMethodChannel(ios_channel: channel) // Set the method channel on the SDK delegate
    }

    // Function to return the method channel
    public static func getChannel() -> FlutterMethodChannel {
        return methodChannel
    }

    // Handling method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodDelegate?.handleMethodCall(call, result: result)
    }
    
    // Cleanup resources if needed (e.g., method channels) when the plugin is deallocated
    deinit {
        VoiceAppLogger.debug(TAG: TAG, message: "in deinit")
//        methodDelegate?.stop()
    }
}
