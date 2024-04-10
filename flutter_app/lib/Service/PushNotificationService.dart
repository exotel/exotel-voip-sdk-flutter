import 'package:firebase_messaging/firebase_messaging.dart';
import '../exotelSDK/ExotelSDKClient.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  Future<void> setupLocalNotification() async {
    const androidInitializationSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInitializationSetting);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
    var service = FlutterBackgroundService();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  void showLocalNotification(String title, String body) {
    const androidNotificationDetail = AndroidNotificationDetails(
      '0', // channel Id
      'general',// channel Name
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetail,
    );
    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  print("RemoteMessage : $message");
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  ExotelSDKClient.getInstance().relayFirebaseMessagingData(message.data);
  PushNotificationService.getInstance().showLocalNotification(
    'Incoming call!',
    '',
  );
}