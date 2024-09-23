import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'ExotelSDKCallback.dart';
import 'MethodChannelInvokeMethod.dart';
import 'package:flutter/services.dart';
import 'ExotelVoiceClient.dart';

class ExotelSDKClient implements ExotelVoiceClient {
  static  MethodChannel? _channel;
  static  EventChannel? _eventChannel;
  static ExotelSDKCallback? _mCallBack;
  static final ExotelSDKClient _instance = ExotelSDKClient._internal();
  static BuildContext? _context;
  static StreamSubscription? _eventSubscription;

  ExotelSDKClient._internal(); // Private constructor

  factory ExotelSDKClient() {
    return _instance;
  }

  static void setCallback(ExotelSDKCallback callback) {
    _mCallBack = callback;
  }

  static void initializeMethodChannel() {
    if(Platform.isAndroid) {
      _channel = MethodChannel('exotel/android_plugin');
      _eventChannel = EventChannel('exotel/android_plugin_event');
    }
    if(Platform.isIOS) {
      _channel = MethodChannel('exotel/ios_plugin');
      _eventChannel = EventChannel('exotel/ios_plugin_event');
    }
    _channel?.setMethodCallHandler(_flutterCallHandler);
    print('ExotelSDKClient initialized');
    _eventSubscription = _eventChannel?.receiveBroadcastStream().listen(_handleEvent, onError: _handleError);
  }

  static void initializePlugin(BuildContext context) {
    _context = context;
    initializeMethodChannel();
  }

  static bool isContextInitialized() {
    return _context != null;
  }

  static BuildContext getContext() {
    if (!isContextInitialized()) {
      throw Exception("Context is not initialized!");
    }
    return _context!;
  }


  @override
   Future<String> getDeviceId() async {
    try {
      return await _channel?.invokeMethod(
          MethodChannelInvokeMethod.GET_DEVICE_ID);
    } catch(e){
      rethrow;
    }
  }

  static Future<void> sendMessage(String message) async {
    print('Sending message: $message');
    await _channel?.invokeMethod('sendMessage', {'message': message});
  }

  @override
  Future<void> initialize(String hostname, String subsriberName, String displayName, String accountSid,String subscriberToken) async {
    var arg = {
      'host_name':hostname,
      'subscriber_name':subsriberName,
      'account_sid':accountSid,
      'subscriber_token':subscriberToken,
      'display_name':displayName
    };

    try {
      await _channel?.invokeMethod(MethodChannelInvokeMethod.INITIALIZE,arg);
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.INITIALIZE}: ${e.toString()}");
      rethrow;
    }
  }

  static Future<void> reInitialize(String hostname, String subsriberName, String displayName, String accountSid,String subscriberToken) async {
    var arg = {
      'host_name':hostname,
      'subscriber_name':subsriberName,
      'account_sid':accountSid,
      'subscriber_token':subscriberToken,
      'display_name':displayName
    };

    try {
      await _channel?.invokeMethod("reInitialize",arg);
    } catch (e) {
      print("Failed to Invoke ${"reInitialize"}: ${e.toString()}");
      rethrow;
    }
  }

  @override
   Future<void> reset() async{
    print("going to reset SDK ");
    _channel?.invokeMethod(MethodChannelInvokeMethod.RESET);
  }

  @override
  Future<void> stop() async{
    print("going to stop SDK ");
    _channel?.invokeMethod(MethodChannelInvokeMethod.STOP);
  }

  @override
   Future<void> dial(String dialTo, String message) async{
    print("call button function start");
    try {
      await _channel?.invokeMethod(MethodChannelInvokeMethod.DIAL, {'dialTo':dialTo,'message':message});
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.DIAL}: ${e.toString()}");
      rethrow;
    }

  }

  @override
   Future<void> mute() async{
    print("mute function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.MUTE)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.MUTE}: ${e.toString()}");
    });
  }

  @override
   Future<void> unmute() async{
    print("unmute function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.UNMUTE)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.UNMUTE}: ${e.toString()}");
    });
  }

  @override
   Future<void> enableSpeaker() async{
    print("enableSpeaker function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.ENABLE_SPEAKER)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ENABLE_SPEAKER}: ${e.toString()}");
    });
  }

  @override
   Future<void> disableSpeaker() async{
    print("disableSpeaker function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.DISABLE_SPEAKER)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.DISABLE_SPEAKER}: ${e.toString()}");
    });
  }

  @override
   Future<void> enableBluetooth() async{
    print("enableBluetooth function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.ENABLE_BLUETOOTH)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ENABLE_BLUETOOTH}: ${e.toString()}");
    });

  }

  @override
   Future<void> disableBluetooth() async{
    print("disableBluetooth function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.DISABLE_BLUETOOTH)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.DISABLE_BLUETOOTH.toString()}");
    });
  }

  @override
   Future<void> hangup() async{
    print("hangup function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.HANGUP)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.HANGUP}: ${e.toString()}");
    });
  }

  @override
   Future<void> answer() async{
    print("answer function start");
    await _channel?.invokeMethod(MethodChannelInvokeMethod.ANSWER)
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.ANSWER}: ${e.toString()}");
      throw e;
    });
  }

  @override
   Future<void> sendDtmf(String digit) async{
    print("sendDtmf function start");
    _channel?.invokeMethod(MethodChannelInvokeMethod.SEND_DTMF,{'digit': digit})
        .catchError((e){
      print("Failed to Invoke ${MethodChannelInvokeMethod.SEND_DTMF}: ${e.toString()}");
    });

  }

  @override
   Future<void> postFeedback(int? rating, String? issue) async{
    print("lastCallFeedback function start");
    print(" rating : $rating issue: $issue");
    try {
      _channel?.invokeMethod(MethodChannelInvokeMethod.POST_FEEDBACK,{'rating': rating, 'issue':issue });
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.POST_FEEDBACK}: ${e.toString()}");
      rethrow;
    }
  }

  @override
   Future<String> getVersionDetails() async{
    print("getVersionDetails function start");
    try {
      return await _channel?.invokeMethod(MethodChannelInvokeMethod.GET_VERSION_DETAILS);
    } catch (e) {
      print("Failed to Invoke ${MethodChannelInvokeMethod.GET_VERSION_DETAILS}: ${e.toString()}");
      rethrow;
    }
  }

  @override
   Future<void> uploadLogs(DateTime startDate, DateTime endDate, String description) async{
    print("uploadLogs function start");

    try {
      String startDateString = startDate.toIso8601String();
      String endDateString = endDate.toIso8601String();
      print("startDateString: $startDateString, endDateString: $endDateString");
      _channel?.invokeMethod(MethodChannelInvokeMethod.UPLOAD_LOGS, {
        'startDateString': startDateString,
        'endDateString': endDateString,
        'description': description,
      });    }
    catch (e) {
      rethrow;
    }
  }

  @override
   void relaySessionData(Map<String, dynamic> data) {
    print('relaySessionData : ${data}');
    Map<String,String> sessionData = {
      "payload":data['payload'].toString(),
      "payloadVersion":data['payloadVersion'].toString()
    };
    print("in relayFirebaseMessagingData");
    _channel?.invokeMethod(MethodChannelInvokeMethod.RELAY_SESSION_DATA,{'data':sessionData});
  }

  // Corrected to be a top-level function
  static Future<dynamic> _flutterCallHandler(MethodCall call) async {
    print('Received method call: ${call.method}');
    final instance = ExotelSDKClient();
    switch (call.method) {
      case "on-initialization-success":
        print("onInitializationSuccess method invoked from Java");
        _mCallBack?.onInitializationSuccess();
        break;
      case "on-initialization-failure":
        var message = call.arguments['data'];
        _mCallBack?.onInitializationFailure(message);
        break;
      case "on-deinitialized":
        var message = call.arguments['data'];
        _mCallBack?.onDeinitialized();
        break;
      case "on-authentication-failure":
        var message = call.arguments['data'];
        _mCallBack?.onAuthenticationFailure(message);
        break;
      case "on-call-initiated":
        _mCallBack?.onCallInitiated();
        break;
      case "on-call-ringing":
        _mCallBack?.onCallRinging();
        break;
      case "on-call-established":
        _mCallBack?.onCallEstablished();
        break;
      case "on-call-ended":
        _mCallBack?.onCallEnded();
        break;
      case "on-missed-call":
        _mCallBack?.onMissedCall();
        break;
      case "on-media-disrupted":
        _mCallBack?.onMediaDisrupted();
        break;
      case "on-renewing-media":
        _mCallBack?.onRenewingMedia();
        break;
      case "on-incoming-call": //to-do: need to refactor, need code optimization
        print("in case incoming in exotelsdkclient.dart");
        String callId = call.arguments['callId'];
        String destination = call.arguments['destination'];
        print(
            'in FlutterCallHandler(), callId is $callId, destination is $destination ');
        _mCallBack?..onCallIncoming(callId, destination);
        break;
      case "on-upload-log-success":
        _mCallBack?..onUploadLogSuccess();
        break;
      case "on-upload-log-failure":
        var message = call.arguments['data'];
        _mCallBack?..onUploadLogFailure(message);
        break;
      case "on-log":
        var level = call.arguments["level"];
        String tag = call.arguments["tag"];
        String message = call.arguments["message"];
        break;
      case "on-version-details":
        var version = call.arguments['version'];
        _mCallBack?..onVersionDetails(version);
        break;
      case 'receiveMessage':
        print('Received message: ${call.arguments}');
        break;
      case 'on-destroy-media-session':
        _mCallBack?..onDestroyMediaSession();
      default:
        print("No Method Handler found for ${call.method}");
        break;
    }
  }


  // static void _handleEvent(dynamic event) {
  //   // Handle the event here
  //   print('Received event: $event');
  //   if (event['eventName'] == 'onInitializationSuccess') {
  //     print("onInitializationSuccess method invoked from Java");
  //     _mCallBack?.onInitializationSuccess();
  //   }
  // }

  static void _handleEvent(dynamic event) {
    // Ensure the event is in the expected format
    if (event is Map) {
      String? eventName = event['eventName'];
      dynamic eventData = event['eventData'];
      switch (eventName) {
        case 'on-initialization-success':
          print("onInitializationSuccess method invoked from Java");
          _mCallBack?.onInitializationSuccess();
          break;
        case 'on-initialization-failure':
          String? message = eventData['message'];
          _mCallBack?.onInitializationFailure(message!);
          break;
        case "on-deinitialized":
          String? message = eventData['data'];
          _mCallBack?.onDeinitialized();
          break;
        case 'on-authentication-failure':
          String? message = eventData['message'];
          _mCallBack?.onAuthenticationFailure(message!);
          break;
        case "on-call-initiated":
          _mCallBack?.onCallInitiated();
          break;
        case "on-call-ringing":
          _mCallBack?.onCallRinging();
          break;
        case "on-call-established":
          _mCallBack?.onCallEstablished();
          break;
        case "on-call-ended":
          _mCallBack?.onCallEnded();
          break;
        case "on-missed-call":
          _mCallBack?.onMissedCall();
          break;
        case "on-media-disrupted":
          _mCallBack?.onMediaDisrupted();
          break;
        case "on-renewing-media":
          _mCallBack?.onRenewingMedia();
          break;
        case 'on-incoming-call':
          String? callId = eventData['callId'];
          String? destination = eventData['destination'];
          _mCallBack?.onCallIncoming(callId!, destination!);
          break;
        case "on-upload-log-success":
          _mCallBack?.onUploadLogSuccess();
          break;
        case "on-upload-log-failure":
          String? message = eventData['message'];
          _mCallBack?.onUploadLogFailure(message!);
          break;
        case "on-version-details":
          String? version = eventData['version'];
          _mCallBack?.onVersionDetails(version!);
          break;
        default:
          print("No event handler found for $eventName");
          break;
      }
    } else {
      print("Received event is not a map: $event");
    }
  }


  static void _handleError(dynamic error) {
    // Handle errors here
    print('Received error: $error');
  }


  @override
  void registerPlatformChannel() {
    // TODO: implement registerPlatformChannel
  }

  @override
  void setExotelSDKCallback(ExotelSDKCallback callback) {
    // TODO: implement setExotelSDKCallback
  }

}

