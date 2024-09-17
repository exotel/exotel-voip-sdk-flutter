
import 'exotel_plugin_platform_interface.dart';

class ExotelPlugin {
  Future<String?> getPlatformVersion() {
    return ExotelPluginPlatform.instance.getPlatformVersion();
  }
}
