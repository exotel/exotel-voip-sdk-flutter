package com.example.my_background_plugin;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class MyBackgroundPlugin implements FlutterPlugin, MethodCallHandler {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "my_background_plugin");
        channel.setMethodCallHandler(new MyBackgroundPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startBackgroundTask":
                startBackgroundTask();
                result.success(null);
                break;
            case "stopBackgroundTask":
                stopBackgroundTask();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void startBackgroundTask() {
        System.out.println("BACKGROUNF NATIVE CODE");
    }

    private void stopBackgroundTask() {
        // Stop your background task here
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
