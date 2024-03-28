// FlutterChannelHandler.dart (Communication Channels):
// Create a new file named FlutterChannelHandler.dart.
// If your app communicates with native code (e.g., platform channels), this file handles those interactions.
// Explanation:
// In this file, you can set up communication channels between Flutter and native code (e.g., Android or iOS).
// Implement platform-specific logic here, such as invoking native APIs.
// Customization:
// Customize the channel names and methods based on your app’s integration needs.


// FlutterChannelHandler.dart

import 'dart:developer';
import 'package:flutter_app/Service/PushNotificationService.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKCallback.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ExotelSDKClient {
  // static const platform = MethodChannel('your_channel_name');

  static final ExotelSDKClient _instance = ExotelSDKClient._internal();

  MethodChannel? androidChannel;

  ExotelSDKCallback? mCallBack;
  static ExotelSDKClient getInstance() {
    return _instance;
  }

  ExotelSDKClient._internal();

  void registerMethodHandler() {
    androidChannel = MethodChannel('android/exotel_sdk');
    // handle messages from android to flutter
    androidChannel!.setMethodCallHandler(flutterCallHandler);
  }
  // Example: A method to invoke a native API
  // static Future<void> invokeNativeApi() async {
  //   try {
  //     await platform.invokeMethod('your_native_method_name');
  //   } on PlatformException catch (e) {
  //     print('Error invoking native API: ${e.message}');
  //   }
  // }
  Future<String> logIn(String userId,String password,String accountSid,String hostname) async{
    log("login button function start");
    try {
      String? fcmToken = "";
      await PushNotificationService.getInstance().getToken().then((value) {
        fcmToken = value;
      });
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      String res = await androidChannel?.invokeMethod('login', {'appHostname': hostname ,'username': userId , 'account_sid': accountSid , 'password':password,'fcm_token':fcmToken});
      return res;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<String> call(String userId, String dialTo) async{
    log("call button function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('call', {'username': userId ,  'dialTo':dialTo});
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }

  }
  Future<String> logout() async{
    log("login button function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('logout');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }

  }

  Future<String> mute() async{
    log("mute function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('mute');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> unmute() async{
    log("unmute function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('unmute');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> enableSpeaker() async{
    log("enableSpeaker function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('enableSpeaker');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> disableSpeaker() async{
    log("disableSpeaker function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('disableSpeaker');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> hangup() async{
    log("hangup function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('hangup');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> answer() async{
    log("answer function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('answer');
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> sendDtmf(String digit) async{
    log("sendDtmf function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('sendDtmf',{'digit': digit});
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }

  Future<String> lastCallFeedback(int? rating, String? issue) async{
    log("lastCallFeedback function start");
    log(" rating : $rating issue: $issue");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      return await androidChannel?.invokeMethod('lastCallFeedback',{'rating': rating, 'issue':issue });
      //loading UI
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      rethrow;
    }
  }


  Future<bool> checkLoginStatus() async{
    log("login button function start");
    try {
      String response = await androidChannel?.invokeMethod('isloggedin');
      return response.toLowerCase() == 'true';
    } catch (e) {
      print("Failed to Invoke: '${e.toString()}'.");
      rethrow;
    }
  }


  Future<bool> loginstatus() async {
    bool isLoggedIn = await checkLoginStatus();
    print('Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  Future<String> checkVersionDetails() async{
    log("checkVersionDetails function start");
    try {
      String response = await androidChannel?.invokeMethod('version');
      return response;
    } catch (e) {
      print("Failed to Invoke: '${e.toString()}'.");
      rethrow;
    }
  }

  Future<String> uploadLogs(DateTime startDate, DateTime endDate, String description) async{
    log("uploadLogs function start");

    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
      String startDateString = startDate.toIso8601String();
      String endDateString = endDate.toIso8601String();
      log("startDateString: $startDateString, endDateString: $endDateString");
      return await androidChannel?.invokeMethod('uploadLogs', {
        'startDateString': startDateString,
        'endDateString': endDateString,
        'description': description,
      });    }
    catch (e) {
      rethrow;
    }
  }

  // Future<int> checkCallDuration() async{
  //   log("checkCallDuration function start");
  //   try {
  //     int response = await androidChannel?.invokeMethod('getCallDuration');
  //     return response;
  //   } catch (e) {
  //     print("Failed to Invoke: '${e.toString()}'.");
  //     rethrow;
  //   }
  // }
  //
  // Future<int> CallDuration() async {
  //   int duration = await checkCallDuration();
  //   print('CallDuration is: $duration');
  //   return duration;
  // }

  static Future<void> requestPermissions() async {
    // You can request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.microphone,
      Permission.notification,
      Permission.nearbyWifiDevices,
      Permission.accessMediaLocation,
      Permission.location,
      // Add other permissions you want to request
    ].request();
    // Check permission status and handle accordingly
  }

  Future<String> flutterCallHandler(MethodCall call) async {
    String loginStatus = "not ready";
    String callingStatus = "blank";
    switch (call.method) {
      case "loggedInStatus":
        loginStatus =  call.arguments.toString();
        log("loginStatus = $loginStatus");
        if(loginStatus == "Ready"){
          mCallBack?.onLoggedInSucess();
        } else {
          mCallBack?.onLoggedInFailure(loginStatus);
        }
        break;
      case "callStatus":
        callingStatus =  call.arguments.toString();
        log("callingStatus = $callingStatus");
        if(callingStatus == "Ringing"){
          mCallBack?.onCallRinging();
        } else if(callingStatus == "Connected"){
          mCallBack?.onCallConnected();
        }
        else if(callingStatus == "Ended"){
          mCallBack?.onCallEnded();
        }
        break;
      case "incoming"://to-do: need to refactor, need code optimization
        String callId = call.arguments['callId'];
        String destination = call.arguments['destination'];
        print('in FlutterCallHandler(), callId is $callId, destination is $destination ');
        mCallBack?.onCallIncoming(call.arguments);
        break;
      default:
        break;
    }
    return "";
  }

  void relayFirebaseMessagingData(Map<String, dynamic> data) {
    androidChannel?.invokeMethod('relayNotificationData',{'data':data});
  }

  void setExotelSDKCallback(ExotelSDKCallback callback) {
    mCallBack = callback;
  }


// Example: A method to listen for events from native code
// static void listenToNativeEvents() {
//   platform.setMethodCallHandler((call) {
//     if (call.method == 'your_native_event_name') {
//       // Handle the event data received from native code
//       final eventData = call.arguments as Map<String, dynamic>;
//       final message = eventData['message'] as String;
//       print('Received native event: $message');
//     }
//     return null;
//   });
// }

// Example: A method to send data to native code
// static Future<void> sendDataToNative(String data) async {
//   try {
//     await platform.invokeMethod('sendData', {'data': data});
//   } on PlatformException catch (e) {
//     print('Error sending data to native code: ${e.message}');
//   }
// }

// Add more methods for other communication needs (e.g., platform-specific APIs)
}
