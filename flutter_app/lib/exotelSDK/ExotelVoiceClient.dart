import 'package:flutter_app/Utils/ApplicationUtils.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKCallback.dart';

abstract class ExotelVoiceClient {

  void setExotelSDKCallback(ExotelSDKCallback callback);
  void registerPlatformChannel();
  Future<String> getDeviceId();
  Future<void> initialize(String hostname, String subsriberName, String displayName, String accountSid,String subscriberToken);
  Future<void> reset();
  Future<void> dial(String dialTo, String message);
  Future<void> mute();
  Future<void> unmute();
  Future<void> enableSpeaker();
  Future<void> disableSpeaker();
  Future<void> enableBluetooth();
  Future<void> disableBluetooth();
  Future<void> hangup();
  Future<void> answer();
  Future<void> sendDtmf(String digit);
  Future<void> postFeedback(int? rating, String? issue);
  Future<String> getVersionDetails();
  Future<void> uploadLogs(DateTime startDate, DateTime endDate, String description);
  void relaySessionData(Map<String, dynamic> data) {}



}