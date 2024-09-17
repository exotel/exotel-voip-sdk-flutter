import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'exotel_plugin_platform_interface.dart';

/// An implementation of [ExotelPluginPlatform] that uses method channels.
class MethodChannelExotelPlugin extends ExotelPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('exotel_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
