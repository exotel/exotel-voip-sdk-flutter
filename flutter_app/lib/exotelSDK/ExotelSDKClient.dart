
import 'dart:developer';
import 'dart:ffi';
import 'package:flutter_app/Utils/ApplicationSharedPreferenceData.dart';
import 'package:flutter_app/exotelSDK/MethodChannelInvokeMethod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/PushNotificationService.dart';
import 'ExotelSDKCallback.dart';
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
  
  Future<String> getDeviceId() async {
    try {
      return await androidChannel?.invokeMethod(
          MethodChannelInvokeMethod.GET_DEVICE_ID);
    } catch(e){
      rethrow;
    }
  }

  Future<void> initialize(String hostname, String subsriberName, String displayName, String accountSid,String subscriberToken) async {
     var arg = {
       'host_name':hostname,
       'subscriber_name':subsriberName,
       'account_sid':accountSid,
       'subscriber_token':subscriberToken,
       'display_name':displayName
     };

     androidChannel?.invokeMethod(MethodChannelInvokeMethod.INITIALIZE,arg)
         .catchError((e) {
         print("Failed to Invoke ${MethodChannelInvokeMethod.INITIALIZE}: ${e.toString()}");
         throw e;
     });

  }

  Future<void> reset() async{
    log("login button function start");
      androidChannel?.invokeMethod(MethodChannelInvokeMethod.RESET);
  }

  Future<void> dial(String dialTo, String message) async{
    log("call button function start");
    try {
      await androidChannel?.invokeMethod(MethodChannelInvokeMethod.DIAL, {'dialTo':dialTo,'message':message});
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.DIAL}: ${e.toString()}");
      rethrow;
    }

  }

  Future<void> mute() async{
    log("mute function start");
      androidChannel?.invokeMethod(MethodChannelInvokeMethod.MUTE)
          .catchError((e){
        print("Failed to Invoke ${MethodChannelInvokeMethod.MUTE}: ${e.toString()}");
      });
  }

  Future<void> unmute() async{
    log("unmute function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.UNMUTE)
    .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.UNMUTE}: ${e.toString()}");
    });
  }

  Future<void> enableSpeaker() async{
    log("enableSpeaker function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.ENABLE_SPEAKER)
    .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ENABLE_SPEAKER}: ${e.toString()}");
    });
  }

  Future<void> disableSpeaker() async{
    log("disableSpeaker function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.DISABLE_SPEAKER)
    .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.DISABLE_SPEAKER}: ${e.toString()}");
    });
  }

  Future<void> enableBluetooth() async{
    log("enableBluetooth function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.ENABLE_BLUETOOTH)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ENABLE_BLUETOOTH}: ${e.toString()}");
    });

  }

  Future<void> disableBluetooth() async{
    log("disableBluetooth function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.DISABLE_BLUETOOTH)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.DISABLE_BLUETOOTH.toString()}");
    });
  }

  Future<void> hangup() async{
    log("hangup function start");
      androidChannel?.invokeMethod(MethodChannelInvokeMethod.HANGUP)
          .catchError((e){
        print("Failed to Invoke ${MethodChannelInvokeMethod.HANGUP}: ${e.toString()}");
      });
  }

  Future<void> answer() async{
    log("answer function start");
    await androidChannel?.invokeMethod(MethodChannelInvokeMethod.ANSWER)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ANSWER}: ${e.toString()}");
      throw e;
    });
  }

  Future<void> sendDtmf(String digit) async{
    log("sendDtmf function start");
    androidChannel?.invokeMethod(MethodChannelInvokeMethod.SEND_DTMF,{'digit': digit})
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.SEND_DTMF}: ${e.toString()}");
    });

  }

  Future<void> postFeedback(int? rating, String? issue) async{
    log("lastCallFeedback function start");
    log(" rating : $rating issue: $issue");
    try {
      androidChannel?.invokeMethod(MethodChannelInvokeMethod.POST_FEEDBACK,{'rating': rating, 'issue':issue });
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.POST_FEEDBACK}: ${e.toString()}");
      rethrow;
    }
  }

  Future<String> getVersionDetails() async{
    log("getVersionDetails function start");
    try {
     return await androidChannel?.invokeMethod(MethodChannelInvokeMethod.GET_VERSION_DETAILS);
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.GET_VERSION_DETAILS}: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> uploadLogs(DateTime startDate, DateTime endDate, String description) async{
    log("uploadLogs function start");

    try {
      String startDateString = startDate.toIso8601String();
      String endDateString = endDate.toIso8601String();
      log("startDateString: $startDateString, endDateString: $endDateString");
      androidChannel?.invokeMethod(MethodChannelInvokeMethod.UPLOAD_LOGS, {
        'startDateString': startDateString,
        'endDateString': endDateString,
        'description': description,
      });    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> contacts() async{
    log("fetch contacts function start");
    String response = "";
    try {
      // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
       await androidChannel?.invokeMethod('contacts');
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
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
      Permission.location,  Permission.bluetoothScan,
      Permission.bluetoothConnect,
      // Add other permissions you want to request
    ].request();
    // Check permission status and handle accordingly
  }

  Future<String> flutterCallHandler(MethodCall call) async {
    String loginStatus = "not ready";
    String callingStatus = "blank";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("flutter method handler got call.method : ${call.method} , arguments : ${call.arguments.toString()}");
    switch (call.method) {
      case "inialize-result":
        var status = call.arguments['status'];
        if(status == "OK"){
          mCallBack?.onLoggedInSucess();
          prefs.setBool(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), true);
        } else{
          var message = call.arguments['data'];
          mCallBack?.onLoggedInFailure(message);
        }
        break;
      case "loggedInStatus":
        loginStatus =  call.arguments.toString();
        mCallBack?.setStatus(loginStatus);
        log("loginStatus = $loginStatus");
        if(loginStatus == "Ready"){
          mCallBack?.onLoggedInSucess();
          await prefs.setBool(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), true);
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
        log("in case incoming in exotelsdkclient.dart");
        String callId = call.arguments['callId'];
        String destination = call.arguments['destination'];
        print('in FlutterCallHandler(), callId is $callId, destination is $destination ');
        mCallBack?.onCallIncoming(callId, destination);
        break;
      default:
        break;
    }
    return "";
  }

  void relayFirebaseMessagingData(Map<String, dynamic> data) {
    print("in relayFirebaseMessagingData");
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
