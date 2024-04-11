package com.exotel.voice_sample;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;

import androidx.annotation.NonNull;


import com.exotel.voice.Call;
import com.exotel.voice.CallIssue;
import com.exotel.voice.CallAudioRoute;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.exotel.voice.ErrorType;
import com.exotel.voice.ExotelVoiceError;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


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
    private Call call;
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
    void registerMethodChannel() {
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
                        case "dial":
                            String dialNumber = call.argument("dialTo");
                            VoiceAppLogger.debug(TAG, "Dial number = " + dialNumber);
                            String contextMessage = call.argument("message");
                            VoiceAppLogger.debug(TAG, "Dial message = " + contextMessage);
                            call(dialNumber,contextMessage);
                            break;
                        case "makeWhatsAppCall":
                            dialNumber = call.argument("dialTo");
                            makeWhatsAppCall(dialNumber);
                            break;
                        case "logout":
                            logout();
                            result.success("logging out");
                            break;
                        case "isloggedin":
                            isloggedin();
                            result.success("set isloggedin");
                            break;
                        case "mute":
                            mute();
                            result.success("mute successful");
                            break;
                        case "unmute":
                            unmute();
                            result.success("unmute successful" );
                            break;
                        case "enableSpeaker":
                            enableSpeaker();
                            result.success("enableSpeaker successful");
                            break;
                        case "disableSpeaker":
                            disableSpeaker();
                            result.success("disableSpeaker successful");
                            break;
                        case "enableBluetooth":
                            enableBluetooth();
                            result.success("enableBluetooth successful");
                            break;
                        case "disableBluetooth":
                            disableBluetooth();
                            result.success("disableBluetooth successful");
                            break;
                        case "hangup":
                            hangup();
                            result.success("hangup successful");
                            break;
                        case "answer":
                            answer();
                            result.success("answer() successful");
                            break;
                        case "getCallDuration":
                            getCallDuration();
                            result.success("getCallDuration successful");
                            break;
                        case "version":
                            getVersionDetails();
                            break;
                        case "sendDtmf":
                            String digit = call.argument("digit");
                            VoiceAppLogger.debug(TAG, "digit = " + digit);
                            if (digit != null && digit.length() == 1) {
                                char digitChar = digit.charAt(0);
                                VoiceAppLogger.debug(TAG, "digitChar = " + digitChar);
                                sendDtmf(digitChar);                            }
                            else {
                                // Handle the case where digit is null or contains more than one character
                            }
                            result.success("getCallDuration successful");
                            break;
                        case "uploadLogs":
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
                                e.printStackTrace();
                            }
                            break;


                        case "lastCallFeedback":
                            int rating = call.argument("rating");
                            String issue = call.argument("issue");
                            CallIssue callIssue;
                            if (issue == "ECHO"){
                                 callIssue = CallIssue.ECHO;
                            }
                            else if (issue == "NO_AUDIO"){
                                 callIssue = CallIssue.NO_AUDIO;
                            }
                            else if (issue == "HIGH_LATENCY"){
                                 callIssue = CallIssue.HIGH_LATENCY;
                            }
                            else if (issue == "CHOPPY_AUDIO"){
                                 callIssue = CallIssue.CHOPPY_AUDIO;
                            }
                            else if (issue == "BACKGROUND_NOISE"){
                                 callIssue = CallIssue.BACKGROUND_NOISE;
                            }
                            else {
                                 callIssue = CallIssue.NO_ISSUE;
                            }
                            VoiceAppLogger.debug(TAG, "callIssue = " + callIssue);
                            VoiceAppLogger.debug(TAG, "rating = " + rating);

                            postFeedback(rating , callIssue);
                            break;
                        case "relayNotificationData":
                            Map<String, String> data = call.argument("data");
                            VoiceAppLogger.debug(TAG, "in java relayNotificationData data = " + data);
                            processPushNotification(data);
                            break;
                        case "contacts":
                            fetchContactList();
                            break;
                        default:
                            System.out.println("FAIL");
                            result.notImplemented();
                            break;

                    }
                }
        );

    }

    /**
     * calling the dial number
     */
    private void call(String dialNumber, String contextMessage) {
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        String updatedDestination = mService.getUpdatedNumberToDial(dialNumber);
        try {
            /**
             * [sdk-calling-flow] calling mediator dial api
             * with exphone number as updatedDestination
             */
            call = mService.dial(updatedDestination, contextMessage);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        if(null != call){
            /**
             * [sdk-calling-flow] setting dialNumber in call context
             */
            mService.setCallContext(mUserName,dialNumber,"");
        }
    }

    Map<String, String> createResponse(String code, String status, String data){
        Map<String,String> result = new HashMap<>();
        result.put("code",code);
        result.put("status",status);
        result.put("data",data);
        return result;
    }

    private void  makeWhatsAppCall(String destination) {
    mService.makeWhatsAppCall(destination);
    }

    private void logout() {
    VoiceAppLogger.debug(TAG, "In logout");
    if (null != mService) {
        VoiceAppLogger.debug(TAG, "Calling reset of service");
        mService.reset();
    }
    SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
    sharedPreferencesHelper.putBoolean(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString(),false);

    VoiceAppLogger.debug(TAG, "Return from logout in HomeActivity");
    }
    private ApplicationSharedPreferenceData isloggedin(){
            return ApplicationSharedPreferenceData.IS_LOGGED_IN;
    }

    @Override
    public void onInitializationSuccess() {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.INIALIZE_RESULT,createResponse("401","OK","Ready"));
        });
    }

    @Override
    public void onInitializationFailure(ExotelVoiceError err) {
        VoiceAppLogger.debug(TAG, "onInitializationFailure");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.INIALIZE_RESULT,createResponse("401","FAIL",err.getErrorMessage()));
        });
    }

    @Override
    public void onAuthFailure() {
        VoiceAppLogger.debug(TAG, "On Authentication failure");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.INIALIZE_RESULT,createResponse("401","FAIL","Authentication failure"));
        });
    }

    @Override
    public void onCallInitiated(Call call) {
        VoiceAppLogger.debug(TAG,"onCallInitiated");
    }

    @Override
    public void onCallRinging(Call call) {
        VoiceAppLogger.debug(TAG, "onCallRinging");
        /**
         * [sdk-calling-flow] sending message to flutter that dialer number is ringing
         */
        uiThreadHandler.post(()->{
            channel.invokeMethod("callStatus", "Ringing");
        });
    }

    @Override
    public void onCallEstablished(Call call) {
        VoiceAppLogger.debug(TAG,"onCallEstablished");
        /**
         * [sdk-calling-flow] sending message to flutter that call is connected
         */
        uiThreadHandler.post(()-> {
            channel.invokeMethod("callStatus", "Connected");
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
            channel.invokeMethod("callStatus", "Ended");
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

    private void answer(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel answer() Start.");
        try {
            mService.answer();
        } catch (Exception e) {
            VoiceAppLogger.debug(TAG, "Exception in answer: " + e.getMessage());
        }
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel answer() end.");
    }


    private int getCallDuration(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getCallDuration() Start.");
        int time = mService.getCallDuration();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getCallDuration() time = " + time);
        return time;
    }

    private void getVersionDetails(){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getVersionDetails() Start.");
        String version = mService.getVersionDetails();
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel getVersionDetails() version = " + version);
        channel.invokeMethod("version", version);
    }

    private void processPushNotification(Map<String, String> remoteData) {
        mService.processPushNotification(remoteData);
    }

    private void sendDtmf(char digitChar) {
        mService.sendDtmf(digitChar);
    }

    private void postFeedback(int rating, CallIssue issue) {
        VoiceAppLogger.debug(TAG, "postFeedback() rating = " + rating);
        VoiceAppLogger.debug(TAG, "postFeedback() issue = " + issue);
        mService.postFeedback(rating , issue);
    }

    private void fetchContactList() {

        OkHttpClient okHttpClient = new OkHttpClient();
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        String url = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.APP_HOSTNAME.toString());
        String accountSid = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString());
        String username = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.USER_NAME.toString());

        url = url + "/accounts/" + accountSid + "/subscribers/" + username + "/contacts";
        VoiceAppLogger.debug(TAG, "contactApiUrl :" + url);
        Request request = new Request.Builder()
                .url(url)
                .build();

        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NonNull okhttp3.Call call, @NonNull IOException e) {
                VoiceAppLogger.error(TAG, "getContactList: Failed to get response"
                        + e.getMessage());
            }

            @Override
            public void onResponse(@NonNull okhttp3.Call call, @NonNull Response response) throws IOException {
                VoiceAppLogger.debug(TAG, "response code :" + response.code());
                String jsonData;
                jsonData = response.body().string();
                JSONObject jsonObject;
                VoiceAppLogger.debug(TAG, "Response body: " + jsonData);
                try {
                    uiThreadHandler.post(()->{
                        channel.invokeMethod("contacts", jsonData);
                    });
                } catch (Exception e) {
                    VoiceAppLogger.error(TAG, "contact exception" + e.getMessage());
                }
                response.body().close();
            }
        });
    }




    private void uploadLogs(Date startDate, Date endDate, String description){
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel uploadLogs() Start.");
        try {
            mService.uploadLogs( startDate,  endDate,  description);
        } catch (Exception e) {
            VoiceAppLogger.debug(TAG, "Exception in uploadLogs: " + e.getMessage());
        }
        VoiceAppLogger.debug(TAG, "ExotelSDKChannel uploadLogs() end.");
    }

    @Override
    public void onMissedCall(String remoteUserId, Date time) {
        VoiceAppLogger.debug(TAG,"onMissedCall");
    }

    @Override
    public void onMediaDisrupted(Call call) {

    }

    @Override
    public void onRenewingMedia(Call call) {

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
            channel.invokeMethod("incoming", arguments);
        });
    }

    public void onUploadLogSuccess() {
        VoiceAppLogger.getSignedUrlForLogUpload();
    }

    @Override
    public void onUploadLogFailure(ExotelVoiceError error) {

    }


}
