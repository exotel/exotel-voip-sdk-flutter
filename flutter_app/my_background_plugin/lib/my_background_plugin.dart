import 'package:flutter/services.dart';

class MyBackgroundPlugin {
  static const MethodChannel _channel =
  const MethodChannel('my_background_plugin');

  static Future<void> startBackgroundTask() async {
    try {
      await _channel.invokeMethod('startBackgroundTask');
    } on PlatformException catch (e) {
      print("Failed to start background task: '${e.message}'.");
    }
  }

  static Future<void> stopBackgroundTask() async {
    try {
      await _channel.invokeMethod('stopBackgroundTask');
    } on PlatformException catch (e) {
      print("Failed to stop background task: '${e.message}'.");
    }
  }
}
