package com.example.my_background_plugin;

import android.content.Context;
import android.app.Activity;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.provider.Settings;
import android.content.Context;

import com.exotel.voice.Call;
import com.exotel.voice.CallAudioRoute;
import com.exotel.voice.CallController;
import com.exotel.voice.CallDetails;
import com.exotel.voice.CallIssue;
import com.exotel.voice.CallListener;
import com.exotel.voice.ErrorType;
import com.exotel.voice.ExotelVoiceClient;
import com.exotel.voice.ExotelVoiceClientEventListener;
import com.exotel.voice.ExotelVoiceClientSDK;
import com.exotel.voice.ExotelVoiceError;
import com.exotel.voice.LogLevel;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.security.InvalidParameterException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class MyBackgroundPlugin implements FlutterPlugin, MethodCallHandler,ActivityAware  {
    private static final String TAG = "MyBackgroundPlugin";

    private Context context;
    private Activity activity;
    private String mSDKHostName;
    private String mAccountSid;
    private String mUserName;
    private String mSubsriberToken;
    private String mDisplayName;
    private MethodChannel channel;
    private ExotelVoiceClient exotelVoiceClient;
    private CallController callController;
    private Call mCall;
    private Call mPreviousCall;
    private ExotelTranslatorService exotelTranslatorService;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "my_background_plugin");
        channel.setMethodCallHandler(this);
        ChannelManager.setupMethodChannel(flutterPluginBinding.getBinaryMessenger());
        exotelTranslatorService = new ExotelTranslatorService();
        context = flutterPluginBinding.getApplicationContext();
        exotelTranslatorService.setContext(context);
        System.out.println("MyBackgroundPlugin initialized in java");
        System.out.println("MyBackgroundPlugin onAttachedToEngine: Context initialized: " + (context != null) + channel);
        Intent serviceIntent = new Intent(context, ExotelTranslatorService.class);
//        context.startService(serviceIntent);
        context.startForegroundService(serviceIntent);

    }
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();

    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;

    }
    @Override
    public void onMethodCall(MethodCall call, Result result) {
        exotelTranslatorService.onMethodCall(call, result); // Delegate the call to NewFile
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }
}
