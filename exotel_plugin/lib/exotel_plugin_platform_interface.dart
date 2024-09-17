import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'exotel_plugin_method_channel.dart';

abstract class ExotelPluginPlatform extends PlatformInterface {
  /// Constructs a ExotelPluginPlatform.
  ExotelPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExotelPluginPlatform _instance = MethodChannelExotelPlugin();

  /// The default instance of [ExotelPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelExotelPlugin].
  static ExotelPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExotelPluginPlatform] when
  /// they register themselves.
  static set instance(ExotelPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
