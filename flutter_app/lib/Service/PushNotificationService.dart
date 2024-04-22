import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/exotelSDK/ExotelVoiceClient.dart';
import 'package:flutter_app/exotelSDK/ExotelVoiceClientFactory.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  FirebaseMessaging? _fcm;
  ExotelVoiceClient? _exotelVoiceClient;
  static PushNotificationService getInstance() {
    return _instance;
  }
  PushNotificationService._internal(){
    _fcm = FirebaseMessaging.instance;
    _exotelVoiceClient = ExotelVoiceClientFactory.getExotelVoiceClient();
  }

  Future initialize() async {
    print("PushNotificationService initialize");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      _exotelVoiceClient?.relaySessionData(message.data);
    }
    );
  }

  Future<String?> getToken() async {
    if(Platform.isIOS) {
      print("getting apns token");
      String? apnsToken = await _fcm?.getAPNSToken();
      print("apnsToken : ${apnsToken}");
    }
    String? token = await _fcm?.getToken();
    print('Token: $token');
    return token;
  }
}