
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKCallback.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_app/main.dart';

class ApplicationUtils implements ExotelSDKCallback {
  String? mUserId;

  String? mPassword;

  String? mAccountSid;

  String? mHostName;

  String? mDialTo;

  String mVersion = "waiting..";

  String? mStatus;

  String? mCallId;

  String? mDestination;


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
      arguments: {'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
    );
  }
  void navigateToConnected() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/connected',
          (Route<dynamic> route) => false,
      arguments: {'dialTo': mDialTo, 'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
    );
  }
  void navigateToIncoming() {
   print("in navigateToIncoming");
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/incoming',
          (Route<dynamic> route) => false,
      arguments: {'dialTo': mDialTo, 'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName, 'callId': mCallId, 'destination':mDestination }, //Hard-coded
    );
  }
  void navigateToRinging() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/ringing',
          (Route<dynamic> route) => false,
      arguments: {'dialTo': mDialTo, 'userId': mUserId, 'password': mPassword, 'displayName': mUserId, 'accountSid': mAccountSid, 'hostname': mHostName }, //Hard-coded
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

  void setUserId(String userId) {
    mUserId = userId;
  }

  void setPassword(String password) {
    mPassword = password;
  }

  void setAccountSid(String accountSid) {
    mAccountSid = accountSid;
  }

  void setHostName(String hostname) {
    mHostName = hostname;
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
  void onCallIncoming(Map<String, String> arguments) {
    String? callId = arguments['callId'];
    String? destination = arguments['destination'];
    setCallId(callId!);
    setDestination(destination!);
    navigateToIncoming();
  }

}