package com.example.my_background_plugin;
//com.exotel.voice_plugin;
import android.content.Context;
import android.app.Activity;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.FlutterJNI;

import android.app.Service;
import android.content.Intent;

public class MyBackgroundPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    //ExotelPlugin
    private static final String TAG = "MyBackgroundPlugin";
    private FlutterJNI flutterJNI = new FlutterJNI();

    private Context context;
    private Activity activity;
    private MethodChannel channel;
    private ExotelTranslatorService exotelTranslatorService;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        ChannelManager.setupMethodChannel(flutterPluginBinding.getBinaryMessenger());
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "exotel/android_plugin");
        channel.setMethodCallHandler(this);
        exotelTranslatorService = ExotelTranslatorService.getInstance();
        flutterJNI.attachToNative();
        context = flutterPluginBinding.getApplicationContext();
        exotelTranslatorService.setContext(context);
        System.out.println("MyBackgroundPlugin initialized in java");
        System.out.println("MyBackgroundPlugin onAttachedToEngine: Context initialized: " + (context != null) + channel);
        Intent serviceIntent = new Intent(context, ExotelTranslatorService.class);
        context.startForegroundService(serviceIntent);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        System.out.println("MyBackgroundPlugin: onAttachedToActivity");
        activity = binding.getActivity();
        exotelTranslatorService.setActivity(activity);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        System.out.println("MyBackgroundPlugin: onDetachedFromActivityForConfigChanges");
        activity = null;
        exotelTranslatorService.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        System.out.println("MyBackgroundPlugin: onReattachedToActivityForConfigChanges");
        activity = binding.getActivity();
        exotelTranslatorService.setActivity(activity);
    }

    @Override
    public void onDetachedFromActivity() {
        System.out.println("MyBackgroundPlugin: onDetachedFromActivity");
        activity = null;
        exotelTranslatorService.setActivity(null);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        exotelTranslatorService.onMethodCall(call, result); // Delegate the call to ExotelTranslatorService
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("MyBackgroundPlugin: onDetachedFromEngine");
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        flutterJNI.attachToNative();
    }
}
