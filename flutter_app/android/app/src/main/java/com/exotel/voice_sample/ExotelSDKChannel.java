package com.exotel.voice_sample;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;


import com.exotel.voice.Call;
import com.exotel.voice.CallIssue;
import com.exotel.voice.CallAudioRoute;


import java.security.InvalidParameterException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.exotel.voice.ErrorType;
import com.exotel.voice.ExotelVoiceError;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import okhttp3.MediaType;


//Exotel Channel Class
// it is a Channel class b/w flutter and native.
public class ExotelSDKChannel implements VoiceAppStatusEvents,CallEvents, LogUploadEvents {
    private static final String CHANNEL = "android/exotel_sdk";
    private static final String TAG = "ExotelSDKChannel";

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    FlutterEngine flutterEngine;

    private VoiceAppService mService;

    private String accountSid;
    private String mUserName;
    private String mPassword;

    private Context context;
    private MethodChannel channel;
    private Call mCall;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());
    private String deviceTokenMessage;
    private static DeviceTokenState deviceTokenState = DeviceTokenState.DEVICE_TOKEN_SEND_SUCCESS;
    private String mAppHostname;
    private String mAccountSid;
    private String mSubsriberToken;
    private String mDisplayName;
    private String mSDKHostName;

    /**
     * Constructor
     * @param flutterEngine flutter engine to register channel
     * @param context activity context
     */
    public ExotelSDKChannel(FlutterEngine flutterEngine, Context context) {
        this.flutterEngine = flutterEngine;
        this.context = context;
        mService = new VoiceAppService(context);
        /**
         * setting event listener to handle incomgin events from mediator class
         */
        mService.addStatusEventListener(ExotelSDKChannel.this);
        mService.addCallEventListener(ExotelSDKChannel.this);
        mService.logUploadEventsListener(ExotelSDKChannel.this);
    }

    /**
     * register channel for communication b/w flutter and android
     */
    void registerPlatformChannel() {
        // Channel is created for communication b/w flutter and native
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL);
        // handle messages from flutter to android native
        channel.setMethodCallHandler(
                (call, result) -> {
                    System.out.println("Entered in Native Android");
                    switch (call.method) {
                        case "get-device-id":
                            String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
                            result.success(androidId);
                            break;
                        case "initialize":
                            mSDKHostName = call.argument("host_name");
                            mAccountSid = call.argument("account_sid");
                            mUserName = call.argument("subscriber_name");
                            mSubsriberToken = call.argument("subscriber_token");
                            mDisplayName = call.argument("display_name");
                            try {
                                mService.initialize(mSDKHostName,mUserName,mAccountSid,mSubsriberToken,mDisplayName);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(),e.getMessage(),e );
                            }
                            break;
                        case "reset":
                            reset();
                        case "dial":
                            String dialNumber = call.argument("dialTo");
                            VoiceAppLogger.debug(TAG, "Dial number = " + dialNumber);
                            String contextMessage = call.argument("message");
                            VoiceAppLogger.debug(TAG, "Dial message = " + contextMessage);
                            try {
                                mCall = mService.dial(dialNumber, contextMessage);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(),"Outgoing call Failed",e );
                            }
                            if(mCall != null){
                                result.success(true);
                            } else {
                                result.error(ErrorType.INTERNAL_ERROR.name(), "Outgoing call not initiated","call instance is null");
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
                                result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(),e);
                            }
                            break;
                        case "send-dtmf":
                            String digit = call.argument("digit");
                            VoiceAppLogger.debug(TAG, "digit = " + digit);
                            try {
                                if (digit == null || digit.length()<1) {
                                    throw new InvalidParameterException("digit is not valid");
                                }
                                char digitChar = digit.charAt(0);
                                mService.sendDtmf(digitChar);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(),e);
                            }
                            break;
                        case "post-feedback":
                            int rating = call.argument("rating");
                            String issue = call.argument("issue");
                            postFeedback(rating , issue);
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
                            VoiceAppLogger.debug(TAG, "startDateString = " + startDateString+ " endDateString = " + endDateString);

                            try {
                                SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
                                Date startDate = formatter.parse(startDateString);
                                Date endDate = formatter.parse(endDateString);

                                VoiceAppLogger.debug(TAG, "startDate = " + startDate);
                                VoiceAppLogger.debug(TAG, "endDate = " + endDate);
                                VoiceAppLogger.debug(TAG, "description = " + description);

                                uploadLogs(startDate, endDate, description);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(),e);
                            }
                            break;
                        case "relay-session-data":
                            Map<String, String> data = call.argument("data");
                            VoiceAppLogger.debug(TAG, "in java relayNotificationData data = " + data);
                            processPushNotification(data);
                            try {
                                Boolean relaySucces = mService.relaySessionData(data);
                                result.success(relaySucces);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(), e.getMessage(),e);
                            }
                            break;
                        default:
                            System.out.println("FAIL");
                            result.notImplemented();
                            break;

                    }
                }
        );

    }

    Map<String, String> createResponse(String data){
        Map<String,String> result = new HashMap<>();
        result.put("data",data);
        return result;
    }
    private void reset() {
        VoiceAppLogger.debug(TAG, "going to reset sdk");
        if (null != mService) {
            VoiceAppLogger.debug(TAG, "Calling reset of service");
            mService.reset();
        }
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        sharedPreferencesHelper.putBoolean(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(),false);

        VoiceAppLogger.debug(TAG, "Reset Done");
    }
    @Override
    public void onInitializationSuccess() {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS,null);
        });
    }

    @Override
    public void onInitializationFailure(ExotelVoiceError err) {
        VoiceAppLogger.debug(TAG, "onInitializationFailure");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE,createResponse(err.getErrorMessage()));
        });
    }

    @Override
    public void onAuthFailure() {
        VoiceAppLogger.debug(TAG, "On Authentication failure");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE,createResponse("Authentication failure"));
        });
    }

    @Override
    public void onCallInitiated(Call call) {
        VoiceAppLogger.debug(TAG,"onCallInitiated");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_INITIATED, null);
        });
    }

    @Override
    public void onCallRinging(Call call) {
        VoiceAppLogger.debug(TAG, "onCallRinging");
        /**
         * [sdk-calling-flow] sending message to flutter that dialer number is ringing
         */
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_RINGING, null);
        });
    }

    @Override
    public void onCallEstablished(Call call) {
        VoiceAppLogger.debug(TAG,"onCallEstablished");
        /**
         * [sdk-calling-flow] sending message to flutter that call is connected
         */
        uiThreadHandler.post(()-> {
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_ESTABLISHED, null);
        });
        VoiceAppLogger.debug(TAG, "Call Established, callId: " + call.getCallDetails().getCallId()
                + " Destination: " + call.getCallDetails().getRemoteId());
        if(mService.getCallAudioState() == CallAudioRoute.BLUETOOTH) {
            mService.enableBluetooth();
        }
    }
    @Override
    public void onCallEnded(Call call) {
        VoiceAppLogger.debug(TAG,"onCallEnded");
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        String userId = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.USER_NAME.toString());
        mService.removeCallContext(userId);
        /**
         * [sdk-calling-flow] sending message to flutter that call is disconnected
         */
        uiThreadHandler.post(()-> {
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_ENDED, null);
        });
    }

    private void mute(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel mute() Start.");
        mService.mute();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel mute() end.");

    }
    private void unmute(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel unmute() Start.");
        mService.unmute();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel unmute() end.");

    }
    private void enableSpeaker(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel enableSpeaker() Start.");
        mService.enableSpeaker();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel enableSpeaker() end.");

    }
    private void disableSpeaker(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel disableSpeaker() Start.");
        mService.disableSpeaker();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel disableSpeaker() end.");

    }
    private void enableBluetooth(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel enableBluetooth() Start.");
        mService.enableBluetooth();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel enableBluetooth() end.");

    }
    private void disableBluetooth(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel disableBluetooth() Start.");
        mService.disableBluetooth();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel disableBluetooth() end.");

    }
    private void hangup(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel hangup() Start.");
        try {
            mService.hangup();
        } catch (Exception e) {
            VoiceAppLogger.debug(TAG, "Exception in hangup: " + e.getMessage());
        }
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel hangup() end.");
    }

    private void answer() throws Exception {
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel answer() Start.");
        mService.answer();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel answer() end.");
    }


    private int getCallDuration(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getCallDuration() Start.");
        int time = mService.getCallDuration();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getCallDuration() time = " + time);
        return time;
    }

    private String getVersionDetails(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getVersionDetails() Start.");
        String version = mService.getVersionDetails();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getVersionDetails() version = " + version);
        return version;
    }

    private void processPushNotification(Map<String, String> remoteData) {
        mService.processPushNotification(remoteData);
    }


    private void postFeedback(int rating, String issue) {
        VoiceAppLogger.debug(TAG, "postFeedback() rating = " + rating);
        VoiceAppLogger.debug(TAG, "postFeedback() issue = " + issue);
        CallIssue callIssue = getCallIssueEnum(issue);
        mService.postFeedback(rating , callIssue);
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



    private void uploadLogs(Date startDate, Date endDate, String description) throws Exception {
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel uploadLogs() Start.");
        mService.uploadLogs( startDate,  endDate,  description);
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel uploadLogs() end.");
    }

    @Override
    public void onMissedCall(String remoteUserId, Date time) {
        VoiceAppLogger.debug(TAG,"onMissedCall");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_MISSED_CALL, null);
        });
    }

    @Override
    public void onMediaDisrupted(Call call) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_MEDIA_DISTRUPTED, null);
        });

    }

    @Override
    public void onRenewingMedia(Call call) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_RENEWING_MEDIA, null);
        });
    }

    @Override
    public void onCallIncoming(Call call) {
        VoiceAppLogger.debug(TAG, "onCallIncoming");
        String callId = call.getCallDetails().getCallId();
        String destination = call.getCallDetails().getRemoteId();
        VoiceAppLogger.debug(TAG, "in onCallIncoming(), callId = " + callId + "destination = " +destination);

        /**
         * [sdk-calling-flow] sending message to flutter that dialer number is ringing
         */
        uiThreadHandler.post(()->{
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("callId", callId);
            arguments.put("destination", destination);
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INCOMING_CALL, arguments);
        });
    }

    public void onUploadLogSuccess() {
        VoiceAppLogger.getSignedUrlForLogUpload();
        channel.invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_SUCCESS,null);
    }

    @Override
    public void onUploadLogFailure(ExotelVoiceError error) {
        channel.invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_FAILURE,createResponse(error.getErrorMessage()));
    }


}
