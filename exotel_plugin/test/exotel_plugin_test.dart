import 'package:flutter_test/flutter_test.dart';
import 'package:exotel_plugin/exotel_plugin.dart';
import 'package:exotel_plugin/exotel_plugin_platform_interface.dart';
import 'package:exotel_plugin/exotel_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExotelPluginPlatform
    with MockPlatformInterfaceMixin
    implements ExotelPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ExotelPluginPlatform initialPlatform = ExotelPluginPlatform.instance;

  test('$MethodChannelExotelPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelExotelPlugin>());
  });

  test('getPlatformVersion', () async {
    ExotelPlugin exotelPlugin = ExotelPlugin();
    MockExotelPluginPlatform fakePlatform = MockExotelPluginPlatform();
    ExotelPluginPlatform.instance = fakePlatform;

    expect(await exotelPlugin.getPlatformVersion(), '42');
  });
}
