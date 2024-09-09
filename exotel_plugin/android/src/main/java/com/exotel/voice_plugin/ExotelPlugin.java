package com.exotel.voice_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.content.ContextCompat;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;

import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ExotelPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    private static final String TAG = "ExotelPlugin";
    private FlutterJNI flutterJNI = new FlutterJNI();
    private Context context;
    private Activity activity;
    private MethodChannel channel;
    private EventChannel eventChannel;
    private static EventChannel.EventSink eventSink;
    private ExotelTranslatorService exotelTranslatorService;
    private static boolean isEngineAttached = false;
    private static final Queue<Runnable> eventQueue = new LinkedList<>();

    @Override
    public synchronized void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        System.out.println("ExotelPlugin onAttachedToEngine");
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "exotel/android_plugin");
        channel.setMethodCallHandler(this);
        ChannelManager.setupMethodChannel(flutterPluginBinding.getBinaryMessenger());
        ChannelManager.setPlugin(this);  // Set plugin instance
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "exotel/android_plugin_event");
        eventChannel.setStreamHandler(this);

        if (context == null) {
            exotelTranslatorService = new ExotelTranslatorService();
            context = flutterPluginBinding.getApplicationContext();
            exotelTranslatorService.setContext(context);
            System.out.println("ExotelPlugin initialized in java");
            System.out.println("ExotelPlugin onAttachedToEngine: Context initialized: " + (context != null));

            if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.FOREGROUND_SERVICE_MICROPHONE) == PackageManager.PERMISSION_GRANTED) {
                startExotelTranslatorService();
            } else {
                // Handle permission request, if needed.
                System.out.println("Permissions not granted to start the service.");
            }
        }
    }

    private void startExotelTranslatorService() {
        if (exotelTranslatorService == null) {
            exotelTranslatorService = new ExotelTranslatorService();
            exotelTranslatorService.setContext(context);
        }
        Intent serviceIntent = new Intent(context, ExotelTranslatorService.class);
        context.startForegroundService(serviceIntent);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        isEngineAttached = true;
        System.out.println("ExotelPlugin onAttachedToActivity: isEngineAttached = " + isEngineAttached);
        System.out.println("eventQueue: " + eventQueue);

        if (ContextCompat.checkSelfPermission(binding.getActivity(), Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(binding.getActivity(), Manifest.permission.FOREGROUND_SERVICE_MICROPHONE) == PackageManager.PERMISSION_GRANTED) {
            startExotelTranslatorService();
        } else {
            // Handle permission not granted scenario
            System.out.println("Permission not granted to start the service.");
        }
        new Handler(Looper.getMainLooper()).postDelayed(() -> processEventQueue(), 5000);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        System.out.println("ExotelPlugin onDetachedFromActivityForConfigChanges");
        // activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        System.out.println("ExotelPlugin onReattachedToActivityForConfigChanges");
        // activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        // activity = null;
        isEngineAttached = false;
        System.out.println("ExotelPlugin onDetachedFromActivity: isEngineAttached = " + isEngineAttached);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        exotelTranslatorService.onMethodCall(call, result);
    }

    @Override
    public synchronized void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("ExotelPlugin onDetachedFromEngine");
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    public void sendEvent(String eventName, Map<String, Object> eventData) {
        System.out.println("in sendEvent()");
        boolean currentEngineAttached;
        synchronized (this) {
            currentEngineAttached = isEngineAttached;
            System.out.println("sendEvent: isEngineAttached = " + currentEngineAttached);
        }

        if (currentEngineAttached && eventSink != null) {
            try {
                Handler handler = new Handler(Looper.getMainLooper());
                handler.post(() -> {
                    Map<String, Object> event = new HashMap<>();
                    event.put("eventName", eventName);
                    event.put("eventData", eventData);
                    eventSink.success(event);
                    System.out.println("eventName: " + eventName);
                    System.out.println("eventData: " + eventData);
                });
            } catch (Exception e) {
                System.out.println("Error sending event: " + e.getMessage());
                eventSink.error("EVENT_ERROR", e.getMessage(), null);
            }
        } else {
            if ("on-incoming-call".equals(eventName) || "on-call-ended".equals(eventName)) {
                System.out.println("Engine not attached or EventSink is null. Queuing event.");
                eventQueue.add(() -> sendEvent(eventName, eventData));
                System.out.println("Queued eventName: " + eventName);
                System.out.println("Queued eventData: " + eventData);
            }
        }
    }

    public static void processEventQueue() {
        if (!eventQueue.isEmpty()) {
            // Create a variable to hold the last event
            Runnable lastEvent = null;

            // Iterate through the eventQueue to find the last event
            while (!eventQueue.isEmpty()) {
                lastEvent = eventQueue.poll();
            }

            // If we found an event, add it back to the queue and process it
            if (lastEvent != null) {
                // Clear the main queue to ensure it's empty
                eventQueue.clear();

                // Add only the last event back to the queue
                eventQueue.add(lastEvent);

                // Process the last event
                System.out.println("Processing last event from queue.");
                eventQueue.poll().run();
            }
        }
    }


}
