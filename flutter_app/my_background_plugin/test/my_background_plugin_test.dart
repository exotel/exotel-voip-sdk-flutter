import 'package:flutter_test/flutter_test.dart';
import 'package:my_background_plugin/my_background_plugin.dart';
import 'package:my_background_plugin/my_background_plugin_platform_interface.dart';
import 'package:my_background_plugin/my_background_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyBackgroundPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyBackgroundPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyBackgroundPluginPlatform initialPlatform = MyBackgroundPluginPlatform.instance;

  test('$MethodChannelMyBackgroundPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyBackgroundPlugin>());
  });

  test('getPlatformVersion', () async {
    MyBackgroundPlugin myBackgroundPlugin = MyBackgroundPlugin();
    MockMyBackgroundPluginPlatform fakePlatform = MockMyBackgroundPluginPlatform();
    MyBackgroundPluginPlatform.instance = fakePlatform;

    expect(await myBackgroundPlugin.getPlatformVersion(), '42');
  });
}
