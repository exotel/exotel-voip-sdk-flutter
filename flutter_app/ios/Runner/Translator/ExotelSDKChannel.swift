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
    
    var flutterEngine:FlutterEngine!
    
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
            default:
                print("default case")
                result(FlutterMethodNotImplemented)
            }
            return
        })
    }
    
    
    
}
