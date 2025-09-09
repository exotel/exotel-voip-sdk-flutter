//
//  ExotelSDKChannel.swift
//  Pods
//
//  Created by Afrah Mahmud on 18/09/24.
//

import Foundation
import ExotelVoice
import UIKit
import Flutter

let missingMicrophonePermissionStr = "Microphone Permission is missing. Please enable microphone permission under \"Settings -> Exotel Voice Sample -> Microphone\" for this app"

class ExotelSDKChannel {
    
    private var channel: FlutterMethodChannel!
    private let TAG = "ExotelSDKChannel"
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
    
    func setMethodChannel(ios_channel: FlutterMethodChannel!){
        if let safeOptional = ios_channel {
            self.channel = safeOptional
            }
        VoiceAppLogger.info(TAG: self.TAG, message: "channel is : \(channel!)")
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            VoiceAppLogger.info(TAG: self.TAG, message: "This is native ios method handler")
            VoiceAppLogger.info(TAG: self.TAG, message: "call.method = \(call.method)")
            VoiceAppLogger.info(TAG: self.TAG, message: "call.argument = \(String(describing: call.arguments))")
            switch call.method {
            case "get-device-id":

                let deviceId = UIDevice.current.identifierForVendor?.uuidString
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
                
            case "reset":
                self.reset()
                
            case "stop":
                self.stop()
                
            case "dial":
                let dialNumber: String = (call.arguments as! [String: String])["dialTo"]!
                let contextMessage: String = (call.arguments as! [String: String])["message"]!
                do {
                    try self.dial(destination: dialNumber, message: contextMessage)
                } catch let error {
                    result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil));
                }
            
            case "mute":
                self.mute()
                
            case "unmute":
                self.unmute()
                
            case "enable-speaker":
                self.enableSpeaker()
                
            case "disable-speaker":
                self.disableSpeaker()
                
            case "enable-bluetooth":
                self.enableBluetooth()
                
            case "disable-bluetooth":
                self.disableBluetooth()
                
            case "hangup":
                self.hangup()
                
            case "answer":
                do {
                    try self.answer()
                } catch {
                    result(FlutterError(code: "ERROR", message: "Unable to Answer", details: nil))
                }
                
            case "send-dtmf":
                let digit:String? = (call.arguments as! [String: String])["digit"]!
                
                if(digit == nil || digit!.isEmpty) {
                    VoiceAppLogger.error(TAG: self.TAG, message: "Unable to send dtmf because digit is nil or emtpy")
                    result(FlutterError(code: "ERROR", message: "Unable to send dtmf", details: nil))
                    return
                }
                let digitChar = digit![digit!.index(digit!.startIndex, offsetBy: 0)]
                do {
                    try self.sendDtmf(digit: digitChar)
                } catch let error {
                    result(FlutterError(code: "ERROR", message: error.localizedDescription , details: nil))
                }
                
            case "post-feedback":
                let rating: Int = (call.arguments as! [String: Int])["rating"]!
                let issue: String = (call.arguments as! [String: String])["issue"]!
                do {
                    try self.postFeedback(rating: rating, issue: issue)
                } catch let error {
                    result(FlutterError(code: "ERROR", message: error.localizedDescription , details: nil))
                }
                
            case "get-call-duration":
                let duration:Int = self.getCallDuration()
                result(duration)
                
            case "get-version-details":
                let version:String = self.getVersionDetails()
                result(version)
                
            case "upload-logs":
                let startDate: String = (call.arguments as! [String: String])["startDateString"]!
                let endDate: String = (call.arguments as! [String: String])["endDateString"]!
                let description: String = (call.arguments as! [String: String])["description"]!
                
                self.uploadLogs(startDateString: startDate, endDateString: endDate, description: description)
                
            case "relay-session-data":
                let data:[String: String] = (call.arguments as! [String: [String:String]])["data"]!
                do {
                    let relaySuccess: Bool = try self.relaySessionData(payload: data)
                    result(relaySuccess)
                } catch let error {
                    result(FlutterError(code: "ERROR", message: error.localizedDescription , details: nil))
                }
                
            default:
                print("default case")
                result(FlutterMethodNotImplemented)
            }
            return
       
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
            
            // Manually trigger initialization success since the new xcframework doesnt call it automatically
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                VoiceAppLogger.info(TAG: self.TAG, message: "Manually triggering initialization success for new xcframework")
                ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS, arguments: nil)
            }        }
    }
    
    func reset(){
        VoiceAppLogger.debug(TAG: TAG, message: "Reset Sample application Service")
        
        if(nil == exotelVoiceClient || !(exotelVoiceClient?.isInitialized() ?? false)) {
            VoiceAppLogger.debug(TAG: TAG, message: "SDK is not yet initialized")
        }
        do {
            try exotelVoiceClient?.reset()
        } catch let resetError as ExotelVoiceError {
            VoiceAppLogger.debug(TAG: TAG, message: "Exception in reset: \(resetError.getErrorMessage())")
        } catch let error {
            VoiceAppLogger.debug(TAG: TAG, message: "\(error.localizedDescription)")
        }
        
        VoiceAppLogger.debug(TAG: TAG, message: "End: Reset in Sample App Service")
    }
    
    func stop(){
        VoiceAppLogger.debug(TAG: TAG, message: "Stop Exotel SDK")
        
        if(nil == exotelVoiceClient || !(exotelVoiceClient?.isInitialized() ?? false)) {
            VoiceAppLogger.debug(TAG: TAG, message: "SDK is not yet initialized")
        }
        do {
            try exotelVoiceClient?.stop()
        } catch let resetError as ExotelVoiceError {
            VoiceAppLogger.debug(TAG: TAG, message: "Exception in stop: \(resetError.getErrorMessage())")
        } catch let error {
            VoiceAppLogger.debug(TAG: TAG, message: "\(error.localizedDescription)")
        }
        
        VoiceAppLogger.debug(TAG: TAG, message: "End: Stop Exotel SDK")
    }
    
    
    func dial(destination: String, message: String) throws  {
        VoiceAppLogger.debug(TAG: TAG, message: "In Dial API in Sample Service, SDK state: \(exotelVoiceClient?.isInitialized() ?? false)")
        VoiceAppLogger.debug(TAG: TAG, message: "Destination is: \(destination)")
        do {
            let _: Call? = try callController?.dial(remoteID: destination, message: message)
        } catch let callError as ExotelVoiceError {
            VoiceAppLogger.debug(TAG: TAG, message: "Exception in dialSDK: \(callError.getErrorMessage())")
            var errMsg = callError.getErrorMessage()
            if callError.getErrorType() == .MISSING_PERMISSION {
                errMsg = missingMicrophonePermissionStr
            }
            throw VoiceAppError(module: TAG, localizedDescription: errMsg)
        } catch let error {
            VoiceAppLogger.debug(TAG: TAG, message: "Genral exception in dialSDK \(error.localizedDescription)")
            
            throw VoiceAppError(module: TAG, localizedDescription: error.localizedDescription)
        }
    }
    
    func mute() {
        if (nil != mCall) {
            mCall?.mute()
        }
    }
    
    func unmute() {
        if(nil != mCall) {
            mCall?.unmute()
        }
    }
    
    func enableSpeaker() {
        if(nil != mCall) {
            mCall?.enableSpeaker()
        }
    }
    
    func disableSpeaker() {
        if (nil != mCall) {
            mCall?.disableSpeaker()
        }
    }
    
    func enableBluetooth() {
        if(nil != mCall) {
            mCall?.enableBluetooth()
        }
    }
    
    func disableBluetooth() {
        if (nil != mCall) {
            mCall?.disableBluetooth()
        }
    }
    
    func getCallAudioState() -> CallAudioRoute {
        if (mCall != nil) {
            return mCall?.getAudioRoute() ?? .EARPIECE
        }
        return .EARPIECE
    }
    
    func hangup() {
        if (nil == mCall) {
            let message = "Call Object is NULL"
            VoiceAppLogger.error(TAG: TAG, message: message)
        }
        do {
            try mCall?.hangup()
        } catch {
            VoiceAppLogger.error(TAG: TAG, message: "Exception in call hangup with CallId: \(String(describing: mCall?.getCallDetails().getCallId()))")
        }
    }
    
    func answer() throws {
        if(nil != mCall) {
            do {
                try mCall?.answer()
            } catch let error {
                VoiceAppLogger.error(TAG: TAG, message: "Exception in call answer ")
                throw VoiceAppError(module: TAG, localizedDescription: error.localizedDescription)
            }
        } else {
            VoiceAppLogger.error(TAG: TAG, message: "Unable to answer because call object is nil")
            throw VoiceAppError(module: TAG, localizedDescription: "Unable to answer")
        }
    }
    
    
    func sendDtmf(digit: Character) throws {
        VoiceAppLogger.debug(TAG: TAG, message: "Sending DTMF digit: \(digit)")
        do {
            try mCall?.sendDtmf(digit: digit)
        } catch let error {
            VoiceAppLogger.error(TAG: TAG, message: "Failed to send DTMF digit: \(digit). Error: \(error.localizedDescription)")
            throw VoiceAppError(module: TAG, localizedDescription: "Failed to send DTMF digit: \(digit)")
        }
    }
    
    func postFeedback(rating: Int, issue: String) throws {
        do {
            if nil != mPreviousCall {
                try mPreviousCall?.postFeedback(rating: rating, issue: CallIssue.stringToEnum(callIssue: issue))
            } else {
                VoiceAppLogger.error(TAG: TAG, message: "Call handle is NULL, cannot post feedback")
            }
        } catch let error {
            VoiceAppLogger.error(TAG: TAG, message: "Post feedback error: \(error.localizedDescription)")
            throw VoiceAppError(module: TAG, localizedDescription: error.localizedDescription)
        }
    }
    
    func getCallDuration() -> Int {
        if (nil == mCall) {
            return -1
        }
        
        let duration:Int = mCall?.getCallDetails().getCallDuration() ?? -1
        return duration
    }
    
    func getVersionDetails()  -> String {
        VoiceAppLogger.debug(TAG: TAG, message: "Getting Version details in sample app")
        let message = ExotelVoiceClientSDK.getVersion()
        DispatchQueue.main.async {
            let response : [String: String] = [
                "version": ExotelVoiceClientSDK.getVersion(),            ]
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_VERSION_DETAILS, arguments: response)
        }
        return message
    }
    
    func uploadLogs(startDateString: String, endDateString: String, description: String) -> Void {
        do {
            let startDate:Date = try convertToDate(dateString: startDateString)
            let endDate:Date = try convertToDate(dateString: endDateString)
            exotelVoiceClient?.uploadLogs(startDate: startDate, endDate: endDate, description: description)
        } catch let error {
            VoiceAppLogger.warning(TAG: self.TAG, message: error.localizedDescription)
        }
    }
    
    func convertToDate(dateString: String) throws -> Date {
        let dateFormatter = DateFormatter()

        // Handle fractional seconds (S up to 9 digits)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = dateFormatter.date(from: dateString) {
            print("Date object:", date)
            return date
        } else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier ?? "com.exotel.voiceflutterapp",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid input provided"]
            )
        }
    }

    func relaySessionData(payload: [String: String]) throws -> Bool {
        if nil != exotelVoiceClient {
            let isRelayed:Bool? = try exotelVoiceClient?.relaySessionData(payload: payload)
            return isRelayed!
        } else {
            VoiceAppLogger.error(TAG: TAG, message: "Incoming Call Error because Exotel Voice client intance is nil")
            throw VoiceAppError(module: TAG, localizedDescription: "Incoming Call Error")
        }
    }
    
    func createResponse(data: String) -> [String: String]{
        let response : [String: String] = [
            "data": data
        ]
        return response;
    }
    
    func onDetach() {
        VoiceAppLogger.debug(TAG: TAG, message: "in func onDetach")
//        DispatchQueue.main.async {
//            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_DETACH_ENGINE, arguments: nil)
//        }
    }
}
    
extension ExotelSDKChannel: ExotelVoiceClientEventListener {
    func onInitializationSuccess() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS, arguments: nil)
        }
    }

    func onDestroyMediaSession() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_DESTROY_MEDIA_SESSION, arguments: nil)
        }
    }

    func onAlreadyIntialized() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
    }
    
    func onInitializationFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
                    ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE, arguments: self.createResponse(data: error.getErrorMessage()))
                }
    }

    
    func onDeinitialized() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_DEINITIALIZED, arguments: nil)
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
        
//        let response : [String: Any] = [
//            "level": level,
//            "tag": tag,
//            "message": message
//        ]
//        DispatchQueue.main.async {
//            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_LOG, arguments: response)
//        }
    }
    
    func onUploadLogSuccess() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_SUCCESS, arguments: nil)
        }
        
    }
    
    func onInitializationDelay() {}
    
    func onUploadLogFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_FAILURE, arguments: nil)
        }
        
    }
    
    func onAuthenticationFailure(error: any ExotelVoice.ExotelVoiceError) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE, arguments: self.createResponse(data: error.getErrorMessage()))
        }
    }
    
    
    
}

extension ExotelSDKChannel: CallListener {
    func onIncomingCall(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        mCall = call
        DispatchQueue.main.async {
            let response : [String: String] = [
                "callId": call.getCallDetails().getCallId(),
                "destination":call.getCallDetails().getRemoteId()
            ]
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INCOMING_CALL, arguments: response)
        }
    }
    
    func onCallInitiated(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "\(#function)")
        mCall = call
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_INITIATED, arguments: nil)
        }
    }
    
    func onCallRinging(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_RINGING, arguments: nil)
        }
        
    }
    
    func onCallEstablished(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_ESTABLISHED, arguments: nil)
        }
    }
    
    func onCallDisrupted() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_MEDIA_DISTRUPTED, arguments: nil)
        }
        
    }
    
    func onCallRenewed() {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_RENEWING_MEDIA, arguments: nil)
        }
    }
    
    func onCallEnded(call: any ExotelVoice.Call) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_ENDED, arguments: nil)
        }
    }
    
    func onMissedCall(remoteId: String, time: Date) {
        VoiceAppLogger.info(TAG: self.TAG, message: "in \(#function)")
        DispatchQueue.main.async {
            ExotelPlugin.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_MISSED_CALL, arguments: nil)
        }
    }
}
