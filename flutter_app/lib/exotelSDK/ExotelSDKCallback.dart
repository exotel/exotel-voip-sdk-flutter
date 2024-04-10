abstract class ExotelSDKCallback {
  void onLoggedInSucess();

  void onLoggedInFailure(String loginStatus);

  void onCallRinging();

  void onCallConnected();

  void onCallEnded();

  void onCallIncoming(String callId, String destination) {}

  void setVersion(String version) {}

  void setjsonData(String jsonData) {}

  void setStatus(String loginStatus) {}
}