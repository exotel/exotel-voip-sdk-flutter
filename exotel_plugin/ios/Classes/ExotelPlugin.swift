import Flutter
import UIKit
import ExotelVoice

public class ExotelPlugin: NSObject, FlutterPlugin {
    private let TAG = "ExotelPlugin"
    var methodDelegate: ExotelSDKChannel?
    public static var methodChannel: FlutterMethodChannel!
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        VoiceAppLogger.debug(TAG: TAG, message: "in deinit")
//        methodDelegate?.onDetach()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "exotel/ios_plugin", binaryMessenger: registrar.messenger())
        
        let instance = ExotelPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        instance.methodDelegate = ExotelSDKChannel() // Initialize your delegate
        methodChannel = channel
        
        let sdkChannel = ExotelSDKChannel()
        sdkChannel.setMethodChannel(ios_channel: channel) // Set the method channel on the SDK delegate
    }

    
    public static func getChannel() -> FlutterMethodChannel {
        return methodChannel
    }

    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodDelegate?.handleMethodCall(call, result: result)
    }
    
    @objc private func appDidEnterBackground() {
        VoiceAppLogger.debug(TAG: TAG, message: "App entered background")
//        methodDelegate?.stop()
    }

    @objc private func appWillTerminate() {
        VoiceAppLogger.debug(TAG: TAG, message: "Performing tasks before termination.")
//        ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_DETACH_ENGINE, arguments: nil)
//        methodDelegate?.hangup()
    }

}
