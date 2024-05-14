// ChannelManager.java
package com.example.my_background_plugin;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;

public class ChannelManager {
    private static MethodChannel channel;

    public static void setupMethodChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "my_background_plugin");
    }

    public static MethodChannel getChannel() {
        return channel;
    }
}
