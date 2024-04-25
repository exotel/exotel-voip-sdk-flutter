import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'my_background_plugin_platform_interface.dart';

/// An implementation of [MyBackgroundPluginPlatform] that uses method channels.
class MethodChannelMyBackgroundPlugin extends MyBackgroundPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('my_background_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
