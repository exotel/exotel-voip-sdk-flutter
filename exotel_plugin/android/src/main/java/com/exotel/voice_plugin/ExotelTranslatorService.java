package com.exotel.voice_plugin;

import androidx.core.app.NotificationCompat;
import androidx.core.app.ServiceCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.content.ContextCompat;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.PendingIntent;

import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;


import com.exotel.voice.Call;
import com.exotel.voice.CallAudioRoute;
import com.exotel.voice.CallDetails;
import com.exotel.voice.CallDirection;
import com.exotel.voice.CallEndReason;
import com.exotel.voice.CallIssue;
import com.exotel.voice.CallState;
import com.exotel.voice.CallStatistics;
import com.exotel.voice.ExotelVoiceClientSDK;
import com.exotel.voice.CallController;
import com.exotel.voice.CallListener;
import com.exotel.voice.ExotelVoiceClient;
import com.exotel.voice.ExotelVoiceClientEventListener;
import com.exotel.voice.ExotelVoiceError;
import com.exotel.voice.LogLevel;

import org.json.JSONObject;

import java.io.IOException;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.Callback;
import okhttp3.Response;


import androidx.core.app.ServiceCompat;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.Service;
import android.app.Activity;
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

import java.security.InvalidParameterException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry;


public class ExotelTranslatorService extends Service implements ExotelVoiceClientEventListener, CallListener {
    private static final String TAG = "ExotelTranslatorService";
    private static ExotelTranslatorService instance = new ExotelTranslatorService();
    private final IBinder binder = new LocalBinder();
    private ExotelVoiceClient exotelVoiceClient;
    private String mSDKHostName;
    private String mAccountSid;
    private String mUserName;
    private String mSubsriberToken;
    private String mDisplayName;
    private CallController callController;
    private static Call mCall;
    private static final String CHANNEL_ID = "exotelVoiceSample";
    private Call mPreviousCall;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());
    private static final int NOTIFICATION_ID = 7;

    private Context context;
    private Activity activity;
    private ExotelPlugin plugin = ChannelManager.getPlugin();



    public ExotelTranslatorService() {
    }
    public static ExotelTranslatorService getInstance(){
        if(instance==null){
            instance=new ExotelTranslatorService();
        }
        return instance;
    }

    void setContext (Context context) {

        this.context = context;

        // Initialize MethodChannel with the given context
//        if (context != null) {
//            BinaryMessenger messenger = (BinaryMessenger) context;
//            ChannelManager.getChannel() = new MethodChannel(messenger, "exotel_plugin"); // Replace "your_channel_name" with your actual ChannelManager.getChannel() name
//
//                  } else {
//            System.out.println("Context is null. Unable to initialize MethodChannel.");
//        }
    }
    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onCreate() {
        VoiceAppLogger.setContext(getApplicationContext());
        VoiceAppLogger.debug(TAG, "Entry: onCreate VoiceAppService");
        super.onCreate();
        createNotificationChannel();
        VoiceAppLogger.debug(TAG, "Exit: onCreate VoiceAppService");
    }

    void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(CHANNEL_ID,
                    "Exotel Voip Sample", NotificationManager.IMPORTANCE_DEFAULT);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }

    Notification createNotification() {
        Intent notificationIntent = new Intent(this, ExotelPlugin.class);
        PendingIntent pendingIntent;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            pendingIntent = PendingIntent.getActivity(this,
                    0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
        } else {
            pendingIntent = PendingIntent.getActivity(this,
                    0, notificationIntent, 0);
        }

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Exotel Voice Application")
                .setContentText("Service is running...")
//                .setSmallIcon(R.drawable.ic_service_icon)
                .setContentIntent(pendingIntent)
                .build();

        return notification;
    }


    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }
    public class LocalBinder extends Binder {
        ExotelTranslatorService getService() {
            return ExotelTranslatorService.this;
        }
    }


    public void makeServiceForeground(Notification notification) {
        VoiceAppLogger.debug(TAG, "Making the service as foreground");

        // Start the service as a foreground service
        startForeground(NOTIFICATION_ID, notification);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        VoiceAppLogger.debug(TAG, "in onStartCommand of ExotelTranslatorService");
        Notification notification = createNotification();
//        makeServiceForeground(notification);
//        return START_NOT_STICKY;
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED) {
            makeServiceForeground(notification);
        } else {
            // Handle the case where permissions are not granted
            stopSelf();
        }
        return START_NOT_STICKY;
    }
    @Override
    public void onDestroy() {
        super.onDestroy();
        VoiceAppLogger.debug(TAG, "Background service destroyed");
    }

    public void onMethodCall(MethodCall call, Result result) {
        System.out.println("in exotel Context initialized: " + (context != null) + ChannelManager.getChannel());
        System.out.println("Entered in Native Android");
        switch (call.method) {
            case "get-device-id":
                if (context != null) {
                    String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
                    result.success(androidId);
                } else {
                    result.error("CONTEXT_NULL", "Context is null", null);
                }
                break;
            case "initialize":
                mSDKHostName = call.argument("host_name");
                mAccountSid = call.argument("account_sid");
                mUserName = call.argument("subscriber_name");
                mSubsriberToken = call.argument("subscriber_token");
                mDisplayName = call.argument("display_name");
                try {
                    initialize(mSDKHostName, mUserName, mAccountSid, mSubsriberToken, mDisplayName);
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(), null);
                }
                break;
            case "reInitialize":
                mSDKHostName = call.argument("host_name");
                mAccountSid = call.argument("account_sid");
                mUserName = call.argument("subscriber_name");
                mSubsriberToken = call.argument("subscriber_token");
                mDisplayName = call.argument("display_name");
                reInitialize();
                break;
            case "reset":
                reset();
                break;
            case "stop":
                stop();
                break;
            case "dial":
                String dialNumber = call.argument("dialTo");
                VoiceAppLogger.debug(TAG, "Dial number = " + dialNumber);
                String contextMessage = call.argument("message");
                VoiceAppLogger.debug(TAG, "Dial message = " + contextMessage);
                try {
                    mCall = dial(dialNumber, contextMessage);
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), "Outgoing call Failed", e);
                }
                if (mCall != null) {
                    result.success(true);
                } else {
                    result.error(ErrorType.INTERNAL_ERROR.name(), "Outgoing call not initiated", "call instance is null");
                }
                break;
            case "mute":
                mute();
                break;
            case "unmute":
                unmute();
                break;
            case "enable-speaker":
                enableSpeaker();
                break;
            case "disable-speaker":
                disableSpeaker();
                break;
            case "enable-bluetooth":
                enableBluetooth();
                break;
            case "disable-bluetooth":
                disableBluetooth();
                break;
            case "hangup":
                hangup();
                break;
            case "answer":
                try {
                    answer();
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(), e);
                }
                break;
            case "send-dtmf":
                String digit = call.argument("digit");
                VoiceAppLogger.debug(TAG, "digit = " + digit);
                try {
                    if (digit == null || digit.length() < 1) {
                        throw new InvalidParameterException("digit is not valid");
                    }
                    char digitChar = digit.charAt(0);
                    sendDtmf(digitChar);
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(), e);
                }
                break;
            case "post-feedback":
                int rating = call.argument("rating");
                String issue = call.argument("issue");
                postFeedback(rating, issue);
                break;
            case "get-call-duration":
                int duration = getCallDuration();
                result.success(duration);
                break;
            case "get-version-details":
                String version = getVersionDetails();
                result.success(version);
                break;
            case "upload-logs":
                VoiceAppLogger.debug(TAG, "ExotelSDKChannel uploadLogs Start.");
                String startDateString = call.argument("startDateString");
                String endDateString = call.argument("endDateString"); // Corrected line
                String description = call.argument("description");
                VoiceAppLogger.debug(TAG, "startDateString = " + startDateString + " endDateString = " + endDateString);

                try {
                    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
                    Date startDate = formatter.parse(startDateString);
                    Date endDate = formatter.parse(endDateString);

                    VoiceAppLogger.debug(TAG, "startDate = " + startDate);
                    VoiceAppLogger.debug(TAG, "endDate = " + endDate);
                    VoiceAppLogger.debug(TAG, "description = " + description);
                    uploadLogs(startDate, endDate, description);
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(), e);
                }
                break;
            case "relay-session-data":
                Map<String, String> data = call.argument("data");
                VoiceAppLogger.debug(TAG, "in java relayNotificationData data = " + data);
                try {
                    Boolean relaySucces = relaySessionData(data);
                    result.success(relaySucces);
                } catch (Exception e) {
                    result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(), e);
                }
                break;
            case "sendMessage":
                String message = call.argument("message");
                sendMessageToFlutter();
                break;
            default:
                System.out.println("FAIL");
                result.notImplemented();
                break;
        }
    }



    public void initialize(String hostname, String subscriberName, String accountSid, String subscriberToken, String displayName) throws Exception {
        VoiceAppLogger.info(TAG, "Initialize Sample App Service");

        exotelVoiceClient = ExotelVoiceClientSDK.getExotelVoiceClient();
        exotelVoiceClient.setEventListener(this);

        VoiceAppLogger.debug(TAG, "Hostname: " + hostname + " SubscriberName: "
                + subscriberName + " AccountSID: " + accountSid + " SubscriberToken: " + subscriberToken);
        if (null == displayName || displayName.trim().isEmpty()) {
            displayName = subscriberName;
            throw new Exception("display name is empty");
        } else {
            try {
                exotelVoiceClient.initialize(this.context, hostname, subscriberName, displayName, accountSid, subscriberToken);
            } catch (Exception e) {
                VoiceAppLogger.error(TAG, "Exception in SDK initialization: " + e.getMessage());
                throw new Exception(e.getMessage());
            }
        }
        callController = exotelVoiceClient.getCallController();
        callController.setCallListener(this);
        VoiceAppLogger.debug(TAG, "Returning from initialize with params in sample service");
    }

    private void stop() {
        VoiceAppLogger.debug(TAG, "going to Stop sdk");
        if (null == exotelVoiceClient || !exotelVoiceClient.isInitialized()) {
            VoiceAppLogger.error(TAG, "SDK is not yet initialized");
        } else {
            exotelVoiceClient.stop();
        }
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        sharedPreferencesHelper.putBoolean(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(),false);

        VoiceAppLogger.debug(TAG, "Stop Done");
    }
    @Override
    public void onDeInitialized() {
        VoiceAppLogger.debug(TAG, "Start: onDeInitialized");
//        synchronized (statusListenerListMutex) {
//            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
//                statusEvents.onDeInitialization();
//            }
//        }
        VoiceAppLogger.debug(TAG, "Exit: onDeInitialized");
    }

    void reset() {
        VoiceAppLogger.info(TAG, "Reset sample application Service");

        if (null == exotelVoiceClient || !exotelVoiceClient.isInitialized()) {
            VoiceAppLogger.error(TAG, "SDK is not yet initialized");
        } else {
            exotelVoiceClient.reset(false);
        }
        VoiceAppLogger.debug(TAG, "End: Reset in sample App Service");
    }

    public Call dial(String destination, String message) throws Exception {
        Call call;
        VoiceAppLogger.debug(TAG, "In dial API in Sample Service, SDK initialized is: "
                + exotelVoiceClient.isInitialized());
        VoiceAppLogger.debug(TAG, "Destination is: " + destination);
        try {
            call = callController.dial(destination,message);
        } catch (Exception e) {
            VoiceAppLogger.error(TAG, "Exception in dial :"+e.getMessage());
            throw new Exception("Error in dial");
        }
        return call;
    }

    public void mute() {
        if (null != mCall) {
            mCall.mute();
        }
    }

    public void unmute() {
        if (null != mCall) {
            mCall.unmute();
        }
    }

    public void enableSpeaker() {
        if (null != mCall) {
            mCall.enableSpeaker();
        }
    }

    public void disableSpeaker() {
        if (null != mCall) {
            mCall.disableSpeaker();
        }
    }

    public void enableBluetooth() {
        if (null != mCall) {
            mCall.enableBluetooth();
        }
    }

    public void disableBluetooth() {
        if (null != mCall) {
            mCall.disableBluetooth();
        }
    }

    public void hangup(){
        if (null == mCall) {
            VoiceAppLogger.warn(TAG,"Error while hangup : Call object is NULL");
            return;
        }
        VoiceAppLogger.debug(TAG, "hangup with callId: " + mCall.getCallDetails().getCallId());
        try {
            mCall.hangup();
        } catch (Exception e) {
            VoiceAppLogger.warn(TAG,"Error while hangup : "+e.getMessage());
        }
        VoiceAppLogger.debug(TAG, "Return from hangup in Sample App Service");
    }

    public void answer() throws Exception {
        VoiceAppLogger.debug(TAG, "Answering call");
        if (null == mCall) {
            String message = "Call object is NULL";
            VoiceAppLogger.warn(TAG,"Error while answer : "+message);
            throw new Exception(message);
        }
        try {
            mCall.answer();
        } catch (Exception e) {
            VoiceAppLogger.warn(TAG,"Error while answer : "+e.getMessage());
            throw new Exception("Error while answer ");
        }
        VoiceAppLogger.debug(TAG, "After Answering call");
    }

    public void sendDtmf(char digit) throws InvalidParameterException {
        VoiceAppLogger.debug(TAG, "Sending DTMF digit: " + digit);
        mCall.sendDtmf(digit);
    }

    void postFeedback(int rating, String issue) throws InvalidParameterException {
        if (null != mPreviousCall) {
            VoiceAppLogger.info(TAG, "postFeedback rating:" + rating);
            VoiceAppLogger.error(TAG, "postFeedback issue:" + issue);
            CallIssue callIssue = getCallIssueEnum(issue);
            mPreviousCall.postFeedback(rating, callIssue);
        } else {
            VoiceAppLogger.error(TAG, "Call handle is NULL, cannot post feedback");
        }
    }
    private CallIssue getCallIssueEnum(String issue) {
        switch (issue){
            case "ECHO": return CallIssue.ECHO;
            case "NO_AUDIO":return CallIssue.NO_AUDIO;
            case "HIGH_LATENCY":return CallIssue.HIGH_LATENCY;
            case "CHOPPY_AUDIO":return CallIssue.CHOPPY_AUDIO;
            case "BACKGROUND_NOISE":return CallIssue.BACKGROUND_NOISE;
            default:return CallIssue.NO_ISSUE;
        }
    }

    public int getCallDuration() {
        if (null == mCall) {
            return -1;
        }
        return mCall.getCallDetails().getCallDuration();
    }

    public String getVersionDetails() {
        VoiceAppLogger.debug(TAG, "Getting version details in sample app service");
        String message = ExotelVoiceClientSDK.getVersion();
        VoiceAppLogger.debug(TAG, "Getting version details in sample app service: "+ message);
//        uiThreadHandler.post(()->{
//            HashMap<String, Object> arguments = new HashMap<>();
//            arguments.put("version", message);
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_VERSION_DETAILS, arguments);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("version", message);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_VERSION_DETAILS, arguments);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
        return message;
    }

    public void uploadLogs(Date startDate, Date endDate, String description) throws Exception {
        VoiceAppLogger.debug(TAG, "uploadLogs: startDate: " + startDate + " EndDate: " + endDate);
        exotelVoiceClient.uploadLogs(startDate, endDate, description);
    }
    public boolean relaySessionData(Map<String, String> data) throws Exception {
        VoiceAppLogger.debug(TAG, "in relaySessionData");
//        exotelVoiceClient = ExotelVoiceClientSDK.getExotelVoiceClient();

        if (exotelVoiceClient != null) {
            try {
                return exotelVoiceClient.relaySessionData(data);
            }
            catch (Exception e) {
                VoiceAppLogger.error(TAG, "Exception in relaySessionData: " + e.getMessage());
                throw new Exception("Exception in relaySessionData");
            }
        } else {
            VoiceAppLogger.error(TAG, "ExotelVoiceClient is null after reinitialization");
            throw new Exception("ExotelVoiceClient is null after reinitialization");
        }
    }


    @Override
    public void onIncomingCall(Call call) {
        mCall = call;
        String callId = call.getCallDetails().getCallId();
        String destination = call.getCallDetails().getRemoteId();
        VoiceAppLogger.debug(TAG, "in onCallIncoming(), callId = " + callId + "destination = " +destination);
        VoiceAppLogger.debug(TAG, "ChannelManager.getChannel() is: " + ChannelManager.getChannel() );
//        uiThreadHandler.post(()->{
//            HashMap<String, Object> arguments = new HashMap<>();
//            arguments.put("callId", callId);
//            arguments.put("destination", destination);
//
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INCOMING_CALL, arguments);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("callId", callId);
            arguments.put("destination", destination);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_INCOMING_CALL, arguments);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    public void reInitialize() {
        try {
            initialize(mSDKHostName, mUserName, mAccountSid, mSubsriberToken, mDisplayName);
        } catch (Exception e) {
            VoiceAppLogger.error(TAG, "Exception in reinitialize: " + e.getMessage() );
        }
    }

    @Override
    public void onDestroyMediaSession() {
     VoiceAppLogger.error(TAG, "in onDestroyMediaSession()" );
    }

    @Override
    public void onCallInitiated(Call call) {
        mCall = call;
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_INITIATED, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_CALL_INITIATED, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onCallRinging(Call call) {
        mCall = call;
        VoiceAppLogger.debug(TAG, "in onCallRinging(), ExotelTranslatorService");
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_RINGING, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_CALL_RINGING, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onCallEstablished(Call call) {
        mCall = call;
//        uiThreadHandler.post(()-> {
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_ESTABLISHED, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_CALL_ESTABLISHED, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onCallEnded(Call call) {
        mCall = null;
        mPreviousCall = call;
//        uiThreadHandler.post(()-> {
//            HashMap<String, String> arguments = new HashMap<>();
//            arguments.put("direction", call.getCallDetails().getCallDirection().toString());
//            arguments.put("end-reason", call.getCallDetails().getCallEndReason().toString());
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_CALL_ENDED, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            HashMap<String, String> arguments = new HashMap<>();
            arguments.put("direction", call.getCallDetails().getCallDirection().toString());
            arguments.put("end-reason", call.getCallDetails().getCallEndReason().toString());
            plugin.sendEvent(MethodChannelInvokeMethod.ON_CALL_ENDED, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }

    }

    @Override
    public void onMissedCall(String s, Date date) {
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_MISSED_CALL, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_MISSED_CALL, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onMediaDisrupted(Call call) {
        mCall = call;
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_MEDIA_DISTRUPTED, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_MEDIA_DISTRUPTED, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onRenewingMedia(Call call) {
        mCall = call;
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_RENEWING_MEDIA, null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_RENEWING_MEDIA, null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onInitializationSuccess() {
        VoiceAppLogger.debug(TAG, "Enter onInitializationSuccess()");
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod("on-inialization-success", null);
//        });
        if (ChannelManager.getChannel() != null) {
            VoiceAppLogger.error(TAG, "Channel is not null" + ChannelManager.getChannel());
            // Instead of using MethodChannel, send the event via EventChannel
            if (plugin != null) {
                VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
                plugin.sendEvent(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS, null);
            }
        } else {
            VoiceAppLogger.error(TAG, "Channel is null. Unable to invoke method.");
        }
    }

    private void sendMessageToFlutter() {
        System.out.println("Sending message to Flutter");
        ChannelManager.getChannel().invokeMethod("receiveMessage", "Hello from Java");
    }

    public void onDeInitialization() {
        uiThreadHandler.post(()->{
            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_DEINITIALIZED,null);
        });
    }

    @Override
    public void onInitializationFailure(ExotelVoiceError exotelVoiceError) {
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onLog(LogLevel logLevel, String tag, String message) {
        if (LogLevel.DEBUG == logLevel) {
            VoiceAppLogger.debug(tag, message);
        } else if (LogLevel.INFO == logLevel) {
            VoiceAppLogger.info(tag, message);
        } else if (LogLevel.WARNING == logLevel) {
            VoiceAppLogger.warn(tag, message);
        } else if (LogLevel.ERROR == logLevel) {
            VoiceAppLogger.error(tag, message);
        }
    }

    @Override
    public void onUploadLogSuccess() {
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_SUCCESS,null);
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_UPLOAD_LOG_SUCCESS,null);
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }

    @Override
    public void onUploadLogFailure(ExotelVoiceError exotelVoiceError) {
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_UPLOAD_LOG_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }


    @Override
    public void onAuthenticationFailure(ExotelVoiceError exotelVoiceError) {
//        uiThreadHandler.post(()->{
//            ChannelManager.getChannel().invokeMethod(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE,createResponse("Authentication failure"));
//        });
        if (plugin != null) {
            VoiceAppLogger.error(TAG, "plugin is not null" + plugin);
            plugin.sendEvent(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE,createResponse("Authentication failure"));
        }
        else {
            VoiceAppLogger.error(TAG, "plugin is null. Unable to invoke method.");
        }
    }
    Map<String, Object> createResponse(String data) {
        Map<String, Object> result = new HashMap<>();
        result.put("data", data);
        return result;
    }

}