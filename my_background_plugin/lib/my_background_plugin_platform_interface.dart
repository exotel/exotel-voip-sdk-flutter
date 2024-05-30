import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'my_background_plugin_method_channel.dart';

abstract class MyBackgroundPluginPlatform extends PlatformInterface {
  /// Constructs a MyBackgroundPluginPlatform.
  MyBackgroundPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyBackgroundPluginPlatform _instance = MethodChannelMyBackgroundPlugin();

  /// The default instance of [MyBackgroundPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyBackgroundPlugin].
  static MyBackgroundPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyBackgroundPluginPlatform] when
  /// they register themselves.
  static set instance(MyBackgroundPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
