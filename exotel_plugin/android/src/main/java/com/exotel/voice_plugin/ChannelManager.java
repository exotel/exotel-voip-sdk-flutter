// ChannelManager.java
package com.exotel.voice_plugin;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;

public class ChannelManager {
    private static MethodChannel channel;
    private static ExotelPlugin plugin;

    public static void setupMethodChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "exotel/android_plugin");
    }

    public static MethodChannel getChannel() {
        return channel;
    }

    public static void setPlugin(ExotelPlugin pluginInstance) {
        plugin = pluginInstance;
    }

    public static ExotelPlugin getPlugin() {
        return plugin;
    }
}

