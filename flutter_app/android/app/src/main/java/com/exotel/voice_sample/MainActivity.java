package com.exotel.voice_sample;



import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Color;
import android.os.IBinder;
import android.widget.TextView;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

// This is the First Class which invoked by flutter
public class MainActivity extends FlutterActivity {
    //    private static String TAG = "MainActivity";
//    private ExotelSDKChannel exotelSDKChannel;
    private static final String CHANNEL = "android/exotel_sdk";
    private MethodChannel channel;
    private static final String TAG = "MainActivity";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        System.out.println("configureFlutterEngine");
        GeneratedPluginRegistrant.registerWith(flutterEngine);

//        exotelSDKChannel = new ExotelSDKChannel(this);
//        exotelSDKChannel.registerPlatformChannel(channel);
//        channel.invokeMethod("flutterChannel","message from android");
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        Intent intent = new Intent(this, ExotelTranslatorService.class);
        startService(intent);
        bindService(intent,connection, BIND_AUTO_CREATE);
//        ExotelTranslatorService exotelTranslatorService = new ExotelTranslatorService();
//        exotelTranslatorService.setContext(this);
//        exotelTranslatorService.registerPlatformChannel(channel);
    }

    private ServiceConnection connection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName className,
                                       IBinder service) {
            ExotelTranslatorService.LocalBinder binder = (ExotelTranslatorService.LocalBinder) service;
            VoiceAppLogger.debug(TAG, "In onServiceConnected() ");
            ExotelTranslatorService exotelTranslatorService  = binder.getService();

            exotelTranslatorService.registerPlatformChannel(channel);

        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
            VoiceAppLogger.debug(TAG, "In onServiceDisconnected() ");

        }
    };
}