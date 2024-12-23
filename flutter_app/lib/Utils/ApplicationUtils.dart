import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:exotel_plugin/ExotelSDKClient.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Utils/ApplicationSharedPreferenceData.dart';
import 'package:exotel_plugin/ExotelSDKCallback.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_app/main.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_app/UI/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/UI/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/PushNotificationService.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInitializationSettings = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<void> showNotification(String title, String body) async {
  const androidNotificationDetails = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const iosNotificationDetails = DarwinNotificationDetails();
  const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}

class ApplicationUtils implements ExotelSDKCallback {
  ApplicationUtils();

  String? mSubscriberName;

  String? mPassword;

  String? mAccountSid;

  String? mAppHostName;

  String? mDialTo;

  String? mVersion;

  String? mStatus;

  String? mCallId;

  String? mDestination;

  String? mJsonData;

  String? mDisplayName;

  var _flutterLocalNotificationsPlugin;

  ApplicationUtils._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  static ApplicationUtils? _instance;
  BuildContext? context;
  bool isLoading = false;

  // Factory constructor with argument
  static ApplicationUtils getInstance(BuildContext buildContext) {
    // Create instance only if it's not already created
    _instance ??= ApplicationUtils._internal();
    _instance!.context = buildContext;
    return _instance!;
  }

  void showLoadingDialog(String message) {
    print("Going to Start loading dialog");
    if (isLoading) return;

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        isLoading = true;
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text(message),
            ],
          ),
        );
      },
    );
    print("Started loading dialog");
  }

  // Future<String?> _getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) {
  //     // import 'dart:io'
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  //   } else if (Platform.isAndroid) {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     return androidDeviceInfo.id; // unique ID on Android
  //   }
  // }

  Future<void> login(String subscriberName, String password, String accountSid,
      String appHostname) async {
    mSubscriberName = subscriberName;
    mPassword = password;
    mAccountSid = accountSid;
    mAppHostName = appHostname;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        ApplicationSharedPreferenceData.ACCOUNT_SID.toString(), accountSid);
    sharedPreferences.setString(
        ApplicationSharedPreferenceData.USER_NAME.toString(), subscriberName);
    sharedPreferences.setString(
        ApplicationSharedPreferenceData.PASSWORD.toString(), password);
    sharedPreferences.setString(
        ApplicationSharedPreferenceData.APP_HOSTNAME.toString(), appHostname);
    print("Calling login API");
    // var deviceInfo = DeviceInfoPlugin();
    // var deviceId = await _getId();
    String? deviceId = "";
    try {
      deviceId = await ExotelSDKClient().getDeviceId();
    } catch (e) {
      print("Error while getting device id : ${e}");
      onInitializationFailure(e.toString());
      return;
    }
    sharedPreferences.setString(
        ApplicationSharedPreferenceData.DEVICE_ID.toString(),
        deviceId.toString());
    String url = appHostname + "/login";

    var jsonData = {
      'user_name': subscriberName,
      'password': password,
      'account_sid': accountSid,
      'device_id': deviceId
    };
    print("login request body : ${jsonData.toString()}");
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(jsonData),
          )
          .timeout(Duration(seconds: 15))
          .catchError((error) {
        print("Error while sending post request for login ${error.toString()}");
        throw error;
      });

      print("Got response for login: ${response.statusCode}");
      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print("Got response body for login : ${responseData}");
        String subscriberToken = jsonEncode(responseData['subscriber_token']);
        print("Subscriber Token is $subscriberToken");
        String sdkHostName = responseData['host_name'];
        String exophone = responseData['exophone'];
        mDisplayName = responseData['contact_display_name'];
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString(
            ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString(),
            subscriberToken);
        sharedPreferences.setString(
            ApplicationSharedPreferenceData.SDK_HOSTNAME.toString(),
            sdkHostName);
        sharedPreferences.setString(
            ApplicationSharedPreferenceData.EXOPHONE.toString(), exophone);
        sharedPreferences.setString(
            ApplicationSharedPreferenceData.CONTACT_DISPLAY_NAME.toString(),
            mDisplayName!);

        String? devicetoken = "";
        devicetoken = await PushNotificationService.getInstance().getToken();

        sendDeviceToken(devicetoken, mAppHostName, subscriberName, accountSid);
      } else {
        // If the server returns an error response, throw an exception
        print(
            "login failed with response code ${response.statusCode} and response body : ");
        print(response.body);
        throw Exception(
            "login failed with response code ${response.statusCode}");
      }
    } catch (e) {
      print("Error while hitting login ${e.toString()}");
      onInitializationFailure(e.toString());
    }
  }

  void stopLoadingDialog() {
    print("Going to Stop loading dialog");
    if (isLoading) {
      Navigator.pop(context!); // Close the loading dialog
      isLoading = false;
      print("Stopped loading dialog");
    }
  }

  void navigateToHome() {
    print("in navigateToHome()");
    if (context == null) {
      print('Context is null');
    } else {
      print('Context is not null');
    }
    Navigator.pushNamedAndRemoveUntil(
      context!,
      '/home',
      (route) => false,
    );
  }

  void navigateToLogin() {
    print("in navigateToLogin()");
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  void navigateToConnected() {
    print("in navigateToConnected()");
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/connected',
      (Route<dynamic> route) => false,
      arguments: {'dialTo': mDialTo},
    );
  }

  void navigateToIncoming() {
    print("in navigateToIncoming");
    Navigator.pushNamed(
      context!,
      '/incoming',
    );
    onCallEnd(mDestination!, true);
  }

  void navigateToRinging() {
    print("Navigating to /ringing with state: Ringing");
    // Add the call to recent calls before navigating
    Navigator.pushNamed(
      context!,
      '/ringing',
      arguments: {'dialTo': mDialTo, 'state': "Ringing"},
    );
    onCallEnd(mDialTo!, false);
  }

  void navigateToStart() {
    print("in navigateToStart()");
    Navigator.pushNamedAndRemoveUntil(
      context!,
      '/',
      (route) => false,
    );
  }

  // void navigateToHome(){
  //     stopLoadingDialog();
  //     Navigator.pushReplacementNamed(
  //       context!,
  //       '/home',
  //       arguments: {'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
  //     );
  // }

  // void navigateToConnected(){
  //   stopLoadingDialog();
  //   Navigator.pushReplacementNamed(
  //     context!,
  //     '/connected',
  //     arguments: {'dialTo': mDialTo, 'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
  //   );
  // }

  // void navigateToRinging(){
  //   stopLoadingDialog();
  //   Navigator.pushReplacementNamed(
  //     context!,
  //     '/ringing',
  //     arguments: {'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
  //   );
  // }

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void setDialTo(String dialTo) {
    mDialTo = dialTo;
  }

  void setDestination(String destination) {
    mDestination = destination;
  }

  void setCallId(String callId) {
    mCallId = callId;
  }

  @override
  void onInitializationSuccess() {
    print("in the main project");
    if (context == null) {
      print('Context is null');
    } else {
      print('Context is not null');
    }
    mStatus = "Ready";
    navigateToHome();
    SharedPreferences.getInstance().then((pref) {
      pref.setBool(
          ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), true);
    });
    fetchContactList();
    getVersionDetails();
  }

  @override
  void onDestroyMediaSession() {
    print("in onDestroyMediaSession");
  }

  @override
  void onDetachEngine() {
    print('in onDetachEngine, hanging up ');
    hangup();
  }

  @override
  void onInitializationFailure(String message) {
    stopLoadingDialog();
    showToast(message);
    SharedPreferences.getInstance().then((value) => value.setBool(
        ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), false));
    navigateToStart();
  }

  @override
  void onDeinitialized() {
    print('in onDeinitialized ');
    SharedPreferences.getInstance().then((value) => value.setBool(
        ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), false));
    navigateToStart();
  }

  @override
  void onAuthenticationFailure(String message) {
    stopLoadingDialog();
    showToast("Authentication fail");
    SharedPreferences.getInstance().then((value) => value.setBool(
        ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(), false));
    navigateToStart();
  }

  @override
  void onCallRinging() {
    print('in onCallRinging ');
    navigateToRinging();
  }

  @override
  void onCallEstablished() {
    navigateToConnected();
  }

  @override
  void onCallEnded() {
    showToast("Ended");
    removeCallContext();
    navigateToHome();
  }

  @override
  void onCallIncoming(String callId, String destination) {
    print("in onCallIncoming application utils");
    setCallId(callId);
    setDestination(destination);
    // showLocalNotification(
    //   'Incoming call!',
    //   '$mDestination',
    // );
    showNotification('Incoming call!', '$mDestination');
    navigateToIncoming();
  }

  // void recentCallsPage(String number, String status) {
  //   DateTime time = DateTime.now();
  //   final newCall = Call(
  //     timeFormatted: '$time',
  //     number: number,
  //     status: status,
  //   );
  //
  //   // Format the time
  //   final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  //
  //   // Update the newCall with the formatted time
  //   newCall.timeFormatted = formattedTime;
  //
  //   // Ensure the context is still valid before adding the call
  //   if (context != null) {
  //     // Add the new call to the list
  //     Provider.of<CallList>(context!, listen: false).addCall(newCall);
  //   }
  // }

  // Somewhere on another page, when the call ends:
  void onCallEnd(String number, bool isIncoming) {
    final now = DateTime.now();
    final formattedTime =
        DateFormat('yyyy-MM-dd HH:mm').format(now); // Format the time

    final call = Call(
      number: number,
      timeFormatted: formattedTime,
      isIncoming: isIncoming,
      status: 'Completed',
    );

    // Access the CallList provider to add the new call
    final callList = Provider.of<CallList>(context!, listen: false);
    callList.addCall(call);
  }

  Future<void> sendDeviceToken(String? devicetoken, String? appHostname,
      String? subscriberName, String? accountSid) async {
    print("Device token ${devicetoken}, subscriberName ${subscriberName}");
    String url = appHostname! +
        "/accounts/" +
        accountSid! +
        "/subscribers/" +
        subscriberName! +
        "/devicetoken";
    print("Device token request is: ${url}");

    var requestBody = {'deviceToken': devicetoken};
    print("Device token request body is: ${requestBody}");
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 15))
          .catchError((error) {
        print("Failed to get response for device token ${error.toString()}");
        throw error;
      });

      print("Got response for devicetoken: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful POST request, handle the response here
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String? sdkHostName = sharedPreferences
            .getString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString());
        String? subscriberToken = sharedPreferences.getString(
            ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString());
        String message = "Hello from flutter";
        // ExotelSDKClient().sendMessage(message)
        ExotelSDKClient()
            .initialize(sdkHostName!, mSubscriberName!, mDisplayName!,
                mAccountSid!, subscriberToken!)
            .catchError((e) {
          onInitializationFailure("Error while Inializing SDK");
        });
      } else {
        // If the server returns an error response, throw an exception
        print(response.body);
        onInitializationFailure("Unable to send device token");
      }
    } on PlatformException catch (e) {
      print("Error while intialize ${e.toString()} ");
      onInitializationFailure("Error while Inializing SDK");
    } on Exception catch (e) {
      print("Error ${e.toString()}");
      onInitializationFailure("Error while sending token");
    }
  }

  void makeIPCall(String dialTo, String message) {
    makeCall("sip:${dialTo}", message);
  }

  Future<void> reinitialize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sdkHostName = sharedPreferences
        .getString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString());
    String? subscriberToken = sharedPreferences
        .getString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString());
    String? mSubscriberName = sharedPreferences
        .getString(ApplicationSharedPreferenceData.USER_NAME.toString());
    String? mDisplayName = sharedPreferences
        .getString(ApplicationSharedPreferenceData.DISPLAY_NAME.toString());
    String? mAccountSid = sharedPreferences
        .getString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString());

    ExotelSDKClient()
        .initialize(sdkHostName!, mSubscriberName!, mDisplayName!,
        mAccountSid!, subscriberToken!);
  }

  Future<void> makeCall(String dialTo, String message) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? exophone = sharedPreferences
        .getString(ApplicationSharedPreferenceData.EXOPHONE.toString());

    setCallContext(dialTo, "").then((value) {
      ExotelSDKClient().dial(exophone!, message).catchError((error) {
        print("Error while dialing out : ${e.toString()}");
        onCallEnded();
      });
    });
  }

  Future<void> setCallContext(String dialTo, String message) async {
    String url = mAppHostName! +
        "/accounts/" +
        mAccountSid! +
        "/subscribers/" +
        mSubscriberName! +
        "/context";
    var requestBody = {'dialToNumber': dialTo, 'message': message};
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: 15))
          .catchError((error) {
        print(
            "Failed to get response for set call context ${error.toString()}");
        throw error;
      });

      print("Got response for setting call context: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("set call context success");
      } else {
        print("set call context fail");
        showToast("fail setting call context");
      }
    } on Exception catch (e) {
      print("Error ${e.toString()}");
      showToast("fail setting call context");
    }
  }

  Future<void> removeCallContext() async {
    String url = mAppHostName! +
        "/accounts/" +
        mAccountSid! +
        "/subscribers/" +
        mSubscriberName! +
        "/context";
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(Duration(seconds: 15))
          .catchError((error) {
        print(
            "Failed to get response for remove call context ${error.toString()}");
        throw error;
      });

      print("Got response for remove call context: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("remove call context success");
      } else {
        print("remove call context fail");
      }
    } on Exception catch (e) {
      print("Error ${e.toString()}");
      showToast("fail removing call context");
    }
  }

  Future<void> fetchContactList() async {
    String url = mAppHostName! +
        "/accounts/" +
        mAccountSid! +
        "/subscribers/" +
        mSubscriberName! +
        "/contacts";
    print("fetch contact list");
    await http
        .get(Uri.parse(url))
        .timeout(Duration(seconds: 15))
        .then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("fetched list : ${response.body.toString()}");
        mJsonData = response.body.toString();
      } else {
        showToast("failed to fetch contact list");
      }
    }).catchError((e) {
      print("Failed to get response for contact list ${e.toString()}");
      showToast("failed to get contact list");
    });
  }

  @override
  void onCallInitiated() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/ringing',
      (Route<dynamic> route) => false,
      arguments: {'state': "Connecting...."},
    );
  }

  @override
  void onMediaDisrupted() {
    // TODO: implement onMediaDisrupted
  }

  @override
  void onMissedCall() {
    // TODO: implement onMissedCall
  }

  @override
  void onRenewingMedia() {
    // TODO: implement onRenewingMedia
  }

  @override
  void onUploadLogFailure(String errorMessage) {
    // TODO: implement onUploadLogFailure
  }

  @override
  void onUploadLogSuccess() {
    // TODO: implement onUploadLogSuccess
  }

  void onVersionDetails(version) {
    mVersion = version;
  }

  void reset() {
    ExotelSDKClient().reset();
  }

  void stop() {
    print('in stop function flutter app');
    ExotelSDKClient().stop();
  }

  Future<void> requestPermissions() async {
    print("requesting for permission");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.microphone,
      Permission.notification,
      Permission.nearbyWifiDevices,
      Permission.accessMediaLocation,
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  getVersionDetails() {
    ExotelSDKClient().getVersionDetails();
  }

  void postFeedback(int? rating, String? issue) {
    ExotelSDKClient().postFeedback(rating, issue);
  }

  void uploadLogs(DateTime startDate, DateTime endDate, String description) {
    ExotelSDKClient().uploadLogs(startDate, endDate, description);
  }

  void enableSpeaker() {
    ExotelSDKClient().enableSpeaker();
  }

  void disableSpeaker() {
    ExotelSDKClient().disableSpeaker();
  }

  void mute() {
    ExotelSDKClient().mute();
  }

  void unmute() {
    ExotelSDKClient().unmute();
  }

  void enableBluetooth() {
    ExotelSDKClient().enableBluetooth();
  }

  void disableBluetooth() {
    ExotelSDKClient().disableBluetooth();
  }

  void hangup() {
    ExotelSDKClient().hangup();
  }

  void sendDtmf(String digit) {
    ExotelSDKClient().sendDtmf(digit);
  }

  void answer() {
    ExotelSDKClient().answer();
  }

  // Future<void> setupLocalNotification() async {
  //   const androidInitializationSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const iosInitializationSetting = DarwinInitializationSettings();
  //   const initSettings = InitializationSettings(android: androidInitializationSetting, iOS: iosInitializationSetting);
  //   await _flutterLocalNotificationsPlugin.initialize(initSettings);
  //   var service = FlutterBackgroundService();
  //   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // }
  //
  // void showLocalNotification(String title, String body) {
  //   const androidNotificationDetail = AndroidNotificationDetails(
  //     '0', // channel Id
  //     'general', // channel Name
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(threadIdentifier: 'thread_id');
  //   const notificationDetails = NotificationDetails(
  //     android: androidNotificationDetail,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //   _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  // }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("in firebaseMessagingBackgroundHandler");
  print('Message data: ${message.data}');

  // Ensure Firebase is initialized
  await Firebase.initializeApp();

  // Initialize local notifications
  await initializeNotifications();

  // Show local notification
  await showNotification('Incoming call!', '');

  //initialize plugin instance
  ExotelSDKClient.initializeMethodChannel();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? sdkHostName = sharedPreferences
      .getString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString());
  String? subscriberToken = sharedPreferences
      .getString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString());
  String? mSubscriberName = sharedPreferences
      .getString(ApplicationSharedPreferenceData.USER_NAME.toString());
  String? mDisplayName = sharedPreferences
      .getString(ApplicationSharedPreferenceData.DISPLAY_NAME.toString());
  String? mAccountSid = sharedPreferences
      .getString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString());

  // Debug print statements to verify the values retrieved from SharedPreferences
  print("SDK Hostname: $sdkHostName");
  print("Subscriber Token: $subscriberToken");
  print("Subscriber Name: $mSubscriberName");
  print("Display Name: $mDisplayName");
  print("Account SID: $mAccountSid");

  // Check if all required values are non-null
  if (sdkHostName != null &&
      mSubscriberName != null &&
      mDisplayName != null &&
      mAccountSid != null &&
      subscriberToken != null) {
    ExotelSDKClient.reInitialize(sdkHostName, mSubscriberName, mDisplayName,
        mAccountSid, subscriberToken);
    ExotelSDKClient().relaySessionData(message.data);
  } else {
    print(
        "Error: One or more required values from SharedPreferences are null.");
  }
}
