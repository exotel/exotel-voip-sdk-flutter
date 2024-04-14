//
//  ExotelSDKChannel.swift
//  Runner
//
//  Created by ashishrastogi on 14/04/24.
//

import Foundation
import ExotelVoice

class ExotelSDKChannel {
    
    var channel:FlutterMethodChannel!
    
    private let TAG = "VoiceAppService"
    private var exotelVoiceClient: ExotelVoiceClient?
    private var callController: CallController?
    private var mCall: Call?
    private var mPreviousCall: Call?
    
    
    private var mSDKHostName:String?
    private var mAccountSid:String?
    private var mUserName:String?
    private var mSubsriberToken:String?
    private var mDisplayName:String?
    
    init() {
    }
    
    func registerMethodChannel(channel: FlutterMethodChannel){
        print("registering ios Method Channel")
        self.channel = channel
        self.channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            print("This is native code ")
            print("call.method = \(call.method)")
            switch call.method {
            case "get-device-id":
                var deviceId = UIDevice.current.identifierForVendor?.uuidString
                print("device id is = \(deviceId ?? "NA")")
                result(deviceId)
            case "initialize":
                print("inialize argument are \(String(describing: call.arguments))")
                self.mSDKHostName = (call.arguments as! [String: String])["host_name"]!
                self.mAccountSid = (call.arguments as! [String: String])["account_sid"]!
                self.mUserName = (call.arguments as! [String: String])["subscriber_name"]!
                self.mSubsriberToken = (call.arguments as! [String: String])["subscriber_token"]!
                self.mDisplayName = (call.arguments as! [String: String])["display_name"]!
                
                VoiceAppLogger.debug(TAG: self.TAG, message: "mSDKHostName : \(self.mSDKHostName!)")
                VoiceAppLogger.debug(TAG: self.TAG, message: "mAccountSid : \(self.mAccountSid!)")
                VoiceAppLogger.debug(TAG: self.TAG, message: "mUserName : \(self.mUserName!)")
                VoiceAppLogger.debug(TAG: self.TAG, message: "mSubsriberToken : \(self.mSubsriberToken!)")
                VoiceAppLogger.debug(TAG: self.TAG, message: "mDisplayName : \(self.mDisplayName!)")
                
                self.initialize(hostname: self.mSDKHostName!, subscriberName: self.mUserName!, accountSid: self.mAccountSid!, subscriberToken: self.mSubsriberToken!, displayName: self.mDisplayName!)
                
            default:
                print("default case")
                result(FlutterMethodNotImplemented)
            }
            return
        })
    }
    
    func initialize(hostname: String, subscriberName: String, accountSid: String, subscriberToken: String, displayName: String) {
        DispatchQueue.main.async {
            
            VoiceAppLogger.debug(TAG: self.TAG, message: "Initialize Sample App service")
            self.exotelVoiceClient = ExotelVoiceClientSDK.getExotelVoiceClient()
            self.exotelVoiceClient?.setEventListener(eventListener: self)
            VoiceAppLogger.debug(TAG: self.TAG, message: "SDK initialized is: \(self.exotelVoiceClient?.isInitialized() ?? false)")
            let content = ["DeviceId": UIDevice.current.identifierForVendor?.uuidString,
                           "DeviceType": "ios"]
            VoiceAppLogger.debug(TAG: self.TAG, message: "content : \(content)")
            self.exotelVoiceClient?.initialize(context: content as [String : Any], hostname: hostname, subscriberName: subscriberName, displayName: displayName, accountSid: accountSid, subscriberToken: subscriberToken)
            self.callController = self.exotelVoiceClient?.getCallController()
            self.callController?.setCallListener(callListener: self)
            
            VoiceAppLogger.debug(TAG: self.TAG, message: "Returning from exotel voice client init")
        }
    }
}
    
extension ExotelSDKChannel: ExotelVoiceClientEventListener {
    func onInitializationSuccess() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            self.channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS, arguments: nil)
        }
    }
    
    func onInitializationFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            self.channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE, arguments: error.getErrorMessage())
        }
    }
    
    func onLog(level: ExotelVoice.LogLevel, tag: String, message: String) {
        if (LogLevel.DEBUG == level) {
            VoiceAppLogger.debug(TAG: tag, message: message)
        } else if (LogLevel.INFO == level) {
            VoiceAppLogger.info(TAG: tag, message: message)
        } else if (LogLevel.WARNING == level) {
            VoiceAppLogger.warning(TAG: tag, message: message)
        } else if (LogLevel.ERROR == level) {
            VoiceAppLogger.error(TAG: tag, message: message)
        }
        
    }
    
    func onUploadLogSuccess() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onUploadLogFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onAuthenticationFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            self.channel.invokeMethod(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE, arguments: error.getErrorMessage())
        }
    }
    
}

extension ExotelSDKChannel: CallListener {
    func onIncomingCall(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallInitiated(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallRinging(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallEstablished(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallDisrupted() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallRenewed() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onCallEnded(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    func onMissedCall(remoteId: String, time: Date) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        
    }
    
    
}
