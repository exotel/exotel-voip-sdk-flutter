import 'package:flutter/cupertino.dart';

abstract class ExotelSDKCallback {
  void onInitializationSuccess();

  void onInitializationFailure(String errorMessage);

  void onDeinitialized();

  void onAuthenticationFailure(String errorMessage);

  void onCallInitiated();

  void onCallRinging();

  void onCallEstablished();

  void onCallEnded();

  void onMissedCall();

  void onMediaDisrupted();

  void onRenewingMedia();

  void onCallIncoming(String callId, String destination);

  void onUploadLogSuccess();

  void onUploadLogFailure(String errorMessage);

  void onVersionDetails(String version);

  void onDestroyMediaSession();

  void onDetachEngine();
}
