// ChannelManager.java
package com.example.my_background_plugin;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;

public class ChannelManager {
    private static MethodChannel channel;

    public static void setupMethodChannel(BinaryMessenger messenger) {
        if (channel == null) {
            channel = new MethodChannel(messenger, "exotel/android_plugin");
        }
    }

    public static MethodChannel getChannel() {
        return channel;
    }
}
