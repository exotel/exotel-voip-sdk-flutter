
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Utils/ApplicationSharedPreferenceData.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKCallback.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_app/main.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:flutter_app/UI/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/PushNotificationService.dart';
import 'package:http/http.dart' as http;

class ApplicationUtils implements ExotelSDKCallback {
  String? mSubscriberName;

  String? mPassword;

  String? mAccountSid;

  String? mAppHostName;

  String? mDialTo;

  String mVersion = "waiting..";

  String? mStatus;

  String? mCallId;

  String? mDestination;

  String? mJsonData;

  String? mDisplayName;

  ApplicationUtils._internal();
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

  void showLoadingDialog(String message){
    if(isLoading)
      return;

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
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  Future<void> login(String subscriberName,String password,String accountSid,String appHostname) async {
    mSubscriberName = subscriberName;
    mPassword = password;
    mAccountSid = accountSid;
    mAppHostName = appHostname;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString(), accountSid);
    sharedPreferences.setString(ApplicationSharedPreferenceData.USER_NAME.toString(), subscriberName);
    sharedPreferences.setString(ApplicationSharedPreferenceData.PASSWORD.toString(), password);
    sharedPreferences.setString(ApplicationSharedPreferenceData.APP_HOSTNAME.toString() , appHostname);
    print("Calling login API");
    // var deviceInfo = DeviceInfoPlugin();
    // var deviceId = await _getId();
    var deviceId ="";
    try {
      deviceId = await ExotelSDKClient.getInstance().getDeviceId();
    } catch (e) {
      print("Error while getting device id : ${e}");
      onLoggedInFailure(e.toString());
      return;
    }
    sharedPreferences.setString(ApplicationSharedPreferenceData.DEVICE_ID.toString(), deviceId.toString());
    String url = appHostname+"/login";

    var jsonData = {
      'user_name':subscriberName,
      'password':password,
      'account_sid':accountSid,
      'device_id':deviceId
    };
    print("login request body : ${jsonData.toString()}");
    try{
       final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      ).timeout(Duration(seconds: 15))
           .catchError((error){
         print("Error while sending post request for login ${error.toString()}");
         throw error;
       });

      print("Got response for login: ${response.statusCode}");
      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print("Got response body for login : ${responseData}");
        String subscriberToken = responseData['subscriber_token'].toString();
        String sdkHostName = responseData['host_name'];
        String exophone = responseData['exophone'];
        mDisplayName = responseData['contact_display_name'];
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString(), subscriberToken);
        sharedPreferences.setString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString(),sdkHostName);
        sharedPreferences.setString(ApplicationSharedPreferenceData.EXOPHONE.toString(),exophone);
        sharedPreferences.setString(ApplicationSharedPreferenceData.CONTACT_DISPLAY_NAME.toString(), mDisplayName!);


        String? devicetoken = await PushNotificationService.getInstance().getToken();
        sendDeviceToken(devicetoken, appHostname, subscriberName, accountSid);
      } else {
        // If the server returns an error response, throw an exception
        print(response.body);
      }
    }catch(e){
      onLoggedInFailure(e.toString());
    }

  }

   var mCallback = (http.Response response) async {

   };
  void stopLoadingDialog(){
    if(isLoading){
      Navigator.pop(context!); // Close the loading dialog
      isLoading = false;
    }
  }
  void navigateToHome() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/home',
          (Route<dynamic> route) => false,
    );
  }
  void navigateToConnected() {
    print("in navigateToConnected()");
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/connected',
          (Route<dynamic> route) => false,
      arguments: {'dialTo': mDialTo },
    );
  }
  void navigateToIncoming() {
   print("in navigateToIncoming");
   recentCallsPage(mDestination!, 'INCOMING');
   PushNotificationService.getInstance().showLocalNotification(
     'Incoming call!',
     '$mDestination',
   );
   WidgetsBinding.instance.addPostFrameCallback((_) {
     Navigator.pushReplacementNamed(
       context!,
       '/incoming',
     );
   });
  }
  void navigateToRinging() {
    recentCallsPage(mDialTo!, 'OUTGOING');
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/ringing',
          (Route<dynamic> route) => false,
      arguments: {'state': "Ringing"}, //Hard-coded
    );
  }
  void navigateToStart() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/',
          (Route<dynamic> route) => false,
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

  void showToast(String message){
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
  void setVersion(String version) {
    mVersion = version;
    print('in setVersion(), version is: $mVersion');
  }
  void setStatus(String status) {
    mStatus = status;
    print('in setStatus(), mStatus is: $mStatus');
  }
  void setjsonData(String jsonData) {
    mJsonData = jsonData;
    print('in setVersion(), mJsonData is: $mJsonData');
  }

  @override
  void onLoggedInSucess() {
    setStatus("Ready");
    navigateToHome();
  }

  @override
  void onLoggedInFailure(String loginStatus) {
    stopLoadingDialog();
    showToast(loginStatus);
    navigateToStart();
  }

  @override
  void onCallRinging() {
    navigateToRinging();
  }

  @override
  void onCallConnected() {
    navigateToConnected();
  }

  @override
  void onCallEnded() {
    showToast("Ended");
    navigateToHome();
  }

  @override
  void onCallIncoming(String callId, String destination) {
    print("in onCallIncoming application utils");
    setCallId(callId);
    setDestination(destination);
    navigateToIncoming();
  }

  void recentCallsPage(String number, String status) {
    DateTime time = DateTime.now();
    final newCall = Call(
      timeFormatted: '$time',
      number: number,
      status: status,
    );

    // Format the time
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);

    // Update the newCall with the formatted time
    newCall.timeFormatted = formattedTime;

    // Add the new call to the list
    Provider.of<CallList>(context!, listen: false).addCall(newCall);
  }

  Future<void> sendDeviceToken(String? devicetoken, String? appHostname, String? subscriberName, String? accountSid) async {
    print("Device token ${devicetoken}, subscriberName ${subscriberName}");
    String url = appHostname! + "/accounts/" + accountSid! + "/subscribers/" + subscriberName! + "/devicetoken";
    print("Device token request is: ${url}");

    var jsonData = {
      'deviceToken': ""
    };
    try{
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      ).timeout(Duration(seconds: 15))
      .catchError((error){
        print("Error while sending post request for device token ${error.toString()}");
        throw error;
      });

      print("Got response for devicetoken: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful POST request, handle the response here
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String? sdkHostName = sharedPreferences.getString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString());
        String? subscriberToken = sharedPreferences.getString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString());
        ExotelSDKClient.getInstance().initialize(sdkHostName!, mSubscriberName!, mDisplayName!, mAccountSid!, subscriberToken!);
      } else {
        // If the server returns an error response, throw an exception
        print(response.body);
      }
    } on PlatformException catch(e){
      print("Error while intialize ${e.toString()} ");
      onLoggedInFailure("Error while Inializing SDK");
    } on Exception catch(e){
      print("Error ${e.toString()}");
      onLoggedInFailure("Error while sending token");
    }

  }
}