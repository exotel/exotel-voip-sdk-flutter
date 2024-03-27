import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/ExotelSDKClient.dart';

class PushNotificationService {

  static final PushNotificationService _instance = PushNotificationService._internal();

  FirebaseMessaging? _fcm;

  static PushNotificationService getInstance() {
    return _instance;
  }
  PushNotificationService._internal(){
    _fcm = FirebaseMessaging.instance;
  }

  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      ExotelSDKClient.getInstance().relayFirebaseMessagingData(message.data);
    }
    );
  }

  Future<String?> getToken() async {
    String? token = await _fcm?.getToken();
    print('Token: $token');
    return token;
  }
}