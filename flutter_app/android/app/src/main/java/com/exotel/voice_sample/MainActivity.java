package com.exotel.voice_sample;



import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

// This is the First Class which invoked by flutter
public class MainActivity extends FlutterActivity {
    //    private static String TAG = "MainActivity";
    private ExotelSDKChannel exotelSDKChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        System.out.println("configureFlutterEngine");
        GeneratedPluginRegistrant.registerWith(flutterEngine);


        exotelSDKChannel = new ExotelSDKChannel(flutterEngine,this);
        exotelSDKChannel.registerMethodChannel();
//        channel.invokeMethod("flutterChannel","message from android");
    }
}
