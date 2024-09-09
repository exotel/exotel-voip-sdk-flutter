package com.exotel.voice_sample;

import android.content.Context;
import android.util.Base64;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.exotel.voice.Call;
import com.exotel.voice.CallController;
import com.exotel.voice.CallDetails;
import com.exotel.voice.CallDirection;
import com.exotel.voice.CallEndReason;
import com.exotel.voice.CallIssue;
import com.exotel.voice.CallListener;
import com.exotel.voice.CallStatistics;
import com.exotel.voice.ExotelVoiceClient;
import com.exotel.voice.ExotelVoiceClientEventListener;
import com.exotel.voice.ExotelVoiceClientSDK;
import com.exotel.voice.ExotelVoiceError;
import com.exotel.voice.LogLevel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * it is a mediator/translator class b/w android native project and exotel SDK.
 */
public class VoiceAppService implements ExotelVoiceClientEventListener, CallListener {

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    private static String TAG = "VoiceAppService";
    private ExotelVoiceClient exotelVoiceClient;
    private CallController callController;
    private List<CallEvents> callEventListenerList = new ArrayList<>();
    private Call mCall;
    private Call mPreviousCall;
    private List<VoiceAppStatusEvents> voiceAppStatusListenerList = new ArrayList<>();
    private List<LogUploadEvents> logUploadEventsList = new ArrayList<>();
    private long ringingStartTime = 0;
    private DatabaseHelper databaseHelper;
    private boolean initializationInProgress = false;
    private String initializationErrorMessage;
    private RingTonePlayback tonePlayback;
    private final Object statusListenerListMutex = new Object();
    private VoiceAppStatus voiceAppStatus = new VoiceAppStatus();
    private Context context;
    String pushNotificationPayloadVersion;
    String pushNotificationPayload;
    boolean relayPushNotification;
    String displayName;

//    private ExotelSDKChannel mChannel;

    public VoiceAppService(Context context) {
        VoiceAppLogger.debug(TAG, "Constructor for sample app service");
        this.context = context;
        databaseHelper = DatabaseHelper.getInstance(context);
        tonePlayback = new RingTonePlayback(context);
        tonePlayback.initializeTonePlayback();
    }

    /**
     * this will call the exotel SDK API for initialization
     * @param hostname http endpoint url
     * @param subscriberName username
     * @param accountSid tenant
     * @param subscriberToken token for enabling call
     * @param displayName username/user number
     * @throws Exception
     */
    public void initialize(String hostname, String subscriberName, String accountSid, String subscriberToken, String displayName) throws Exception {
        VoiceAppLogger.info(TAG, "Initialize Sample App Service");
        initializationErrorMessage = null;
        /* Initialize the SDK */
        /**
         * [sdk-initialization-flow] fetching exotel client instance
         * and setting event listener to handle incoming events from exotel client.
         * this class has implemented APIs of ExotelVoiceClientEventListener for handling events.
         */
        exotelVoiceClient = ExotelVoiceClientSDK.getExotelVoiceClient();
        exotelVoiceClient.setEventListener(this);

        VoiceAppLogger.debug(TAG, "Set is Logged in to True");

        VoiceAppLogger.debug(TAG, "SDK initialized is: " + exotelVoiceClient.isInitialized()
                + "Init in Progress is: " + initializationInProgress);

        VoiceAppLogger.debug(TAG, "Hostname: " + hostname + " SubscriberName: "
                + subscriberName + " AccountSID: " + accountSid + " SubscriberToken: " + subscriberToken);
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        sharedPreferencesHelper.putString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString(), subscriberToken);
        sharedPreferencesHelper.putString(ApplicationSharedPreferenceData.APP_HOSTNAME.toString(), hostname);
        sharedPreferencesHelper.putString(ApplicationSharedPreferenceData.USER_NAME.toString(), subscriberName);
        sharedPreferencesHelper.putString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString(), accountSid);
        if (null == displayName || displayName.trim().isEmpty()) {
            displayName = subscriberName;
        } else {
            try {
                initializationInProgress = true;
                /**
                 * [sdk-initialization-flow] initialize the Exotel client
                 */
                exotelVoiceClient.initialize(context, hostname, subscriberName, displayName, accountSid, subscriberToken);
            } catch (Exception e) {
                initializationInProgress = false;
                VoiceAppLogger.error(TAG, "Exception in SDK initialization: " + e.getMessage());
                initializationErrorMessage = e.getMessage();
                throw new Exception(e.getMessage());
            }
        }
        /**
         * [sdk-calling-flow] fetching call controller instance
         * and setting call event listener to handle incoming call events from exotel client.
         * this class has implemented APIs of CallListener for handling call events.
         */
        callController = exotelVoiceClient.getCallController();
        callController.setCallListener(this);
        /* Temp - Added for Testing */
        CallDetails callDetails = callController.getLatestCallDetails();
        if (null != callDetails) {
            VoiceAppLogger.debug(TAG, "callId: " + callDetails.getCallId() + " remoteId: "
                    + callDetails.getRemoteId() + "duration: " + callDetails.getCallDuration()
                    + " callState: " + callDetails.getCallState());
        }

        /* End */
        VoiceAppLogger.debug(TAG, "Returning from initialize with params in sample service");
    }

    /**
     * Stop  the exotel client sdk
     */
    void stop() {
        VoiceAppLogger.info(TAG, "Stop sample application Service");

        if (null == exotelVoiceClient || !exotelVoiceClient.isInitialized()) {
            VoiceAppLogger.error(TAG, "SDK is not yet initialized");
        } else {
            exotelVoiceClient.stop();
        }
        VoiceAppLogger.debug(TAG, "End: Stop in sample App Service");
    }

    /**
     * reset the exotel client sdk
     */
    void reset() {
        VoiceAppLogger.info(TAG, "Reset sample application Service");

        if (null == exotelVoiceClient || !exotelVoiceClient.isInitialized()) {
            VoiceAppLogger.error(TAG, "SDK is not yet initialized");
        } else {
            //exotelVoipClient.reset();
            exotelVoiceClient.reset(false);
        }
        VoiceAppLogger.debug(TAG, "End: Reset in sample App Service");
    }

    /**
     * mediator API for dialing
     * @param destination exophone number
     * @param message
     * @return
     * @throws Exception
     */
    public Call dial(String destination, String message) throws Exception {

        return dialSDK(destination, message);
    }

    /**
     * mediator API to invoke dial of exotel client
     * @param destination exophone number
     * @param message
     * @return
     * @throws Exception
     */
    private Call dialSDK(String destination, String message) throws Exception {
        Call call;

        VoiceAppLogger.debug(TAG, "In dial API in Sample Service, SDK initialized is: "
                + exotelVoiceClient.isInitialized());

        //destination = "sip." + destination;
        VoiceAppLogger.debug(TAG, "Destination is: " + destination);
        try {
            /*if(null == message || message.trim().isEmpty()) {
                call = callController.dial(destination);
            } else {
                call = callController.dialWithMessage(destination,message);
            }*/
            /**
             * [sdk-calling-flow] invoking dial API of exotel client API
             * with exophone
             */
            call = callController.dial(destination,message);

        } catch (Exception e) {
            VoiceAppLogger.error(TAG, "Exception in dial");
            String lastDialledNo;

            SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
            lastDialledNo = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.LAST_DIALLED_NO.toString());
            Date date = new Date();
            if (!e.getMessage().contains("Invalid number")) {
                databaseHelper.insertData(lastDialledNo, date, CallType.OUTGOING);
            }
            throw new Exception(e.getMessage());
        }

        mCall = call;
        return call;
    }

    /*
    public Call dialWithMessage (String destination, String message) throws Exception{

        return dialSDK(destination,message);
    }*/

    public void addCallEventListener(CallEvents callEvents) {
        VoiceAppLogger.debug(TAG, "Adding call event listener: " + callEvents);
        callEventListenerList.add(callEvents);
        for (CallEvents events : callEventListenerList) {
            VoiceAppLogger.debug(TAG, "Listener is: " + events);
        }
    }
    public void logUploadEventsListener(LogUploadEvents logUploadEvents) {
        synchronized (statusListenerListMutex) {
            logUploadEventsList.add(logUploadEvents);
        }

    }
    public void removeCallEventListener(CallEvents callEvents) {
        VoiceAppLogger.debug(TAG, "Remvoing call event listener: " + callEvents + " Class name: " + callEvents.getClass().getName());
        List<CallEvents> removeList = new ArrayList<>();
        for (CallEvents events : callEventListenerList) {
            VoiceAppLogger.debug(TAG, "Listener is: " + events + " Class is : " + events.getClass().getName());
            if (callEvents.getClass().getName().equals(events.getClass().getName())) {
                removeList.add(events);
            }
        }
        callEventListenerList.removeAll(removeList);
    }

    public void addStatusEventListener(VoiceAppStatusEvents statusEvents) {
        synchronized (statusListenerListMutex) {
            voiceAppStatusListenerList.add(statusEvents);
        }

    }

    public void removeStatusEventListener(VoiceAppStatusEvents statusEvents) {
        synchronized (statusListenerListMutex) {
            voiceAppStatusListenerList.remove(statusEvents);
        }

    }
    public CallDetails getLatestCallDetails() {
        VoiceAppLogger.debug(TAG, "getCurrentCallDetails");
        if (null == callController) {
            return null;
        }
        return callController.getLatestCallDetails();
    }

    public String getVersionDetails() {
        VoiceAppLogger.debug(TAG, "Getting version details in sample app service");
        String message;
        message = ExotelVoiceClientSDK.getVersion();
        VoiceAppLogger.debug(TAG, "Getting version details in sample app service: "+ message);
        return message;
    }

    public void hangup() throws Exception {
        if (null == mCall) {
            String message = "Call object is NULL";
            throw new Exception(message);
        }
        VoiceAppLogger.debug(TAG, "hangup with callId: " + mCall.getCallDetails().getCallId());
        try {
            mCall.hangup();
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }

        VoiceAppLogger.debug(TAG, "Return from hangup in Sample App Service");
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

    public void answer() throws Exception {
        VoiceAppLogger.debug(TAG, "Answering call");
        if (null == mCall) {
            String message = "Call object is NULL";
            throw new Exception(message);
        }
        try {
            tonePlayback.stopTone();
            mCall.answer();
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }

        VoiceAppLogger.debug(TAG, "After Answering call");

    }

    public void sendDtmf(char digit) throws InvalidParameterException {
        VoiceAppLogger.debug(TAG, "Sending DTMF digit: " + digit);
        mCall.sendDtmf(digit);
    }

    void postFeedback(int rating, CallIssue issue) throws InvalidParameterException {
        if (null != mPreviousCall) {
            mPreviousCall.postFeedback(rating, issue);
            VoiceAppLogger.error(TAG, "VoiceAppSerive rating:" + rating);
            VoiceAppLogger.error(TAG, "VoiceAppSerive issue:" + issue);

        } else {
            VoiceAppLogger.error(TAG, "Call handle is NULL, cannot post feedback");
        }
    }

    public int getCallDuration() {
        if (null == mCall) {
            return -1;
        }
        return mCall.getCallDetails().getCallDuration();
    }

    public CallStatistics getStatistics() {
        if (null == mCall) {
            return null;
        }
        return mCall.getStatistics();
    }

    /*uncomment the below code to get ringing duration.*/
    /*public int getRingingDuration() {
        long curTime = System.currentTimeMillis() / 1000L;
        int diff = (int) (curTime - ringingStartTime);

        return diff;
    }*/

    public VoiceAppStatus getCurrentStatus() {
        if (exotelVoiceClient == null) {
            VoiceAppLogger.debug(TAG,"VoIP Client not initialized");
            voiceAppStatus.setState(VoiceAppState.STATUS_NOT_INITIALIZED);
            voiceAppStatus.setMessage("Not Initialized");
        } else if (initializationInProgress) {
            VoiceAppLogger.debug(TAG, "Initialization In Progress");
            voiceAppStatus.setState(VoiceAppState.STATUS_INITIALIZATION_IN_PROGRESS);
            voiceAppStatus.setMessage("In Progress");
        } else {
            boolean isSDKInitialized = exotelVoiceClient.isInitialized();
            if (isSDKInitialized) {
                VoiceAppLogger.debug(TAG, "SDK initialized : READY");
                voiceAppStatus.setState(VoiceAppState.STATUS_READY);
                voiceAppStatus.setMessage("Ready");
            }
        }
        return voiceAppStatus;
    }

    /* Implementation of ExotelVoipClientEventListener events */

    /**
     * handle the incoming event from exotel client SDK
     * when SDK is initialized successfully
     */
    @Override
    public void onInitializationSuccess() {

        VoiceAppLogger.debug(TAG, "Start: onStatusChange");
        initializationInProgress = false;
        initializationErrorMessage = null;
        VoiceAppLogger.debug(TAG, "Initialization of SDK success");

        voiceAppStatus.setState(VoiceAppState.STATUS_READY);
        voiceAppStatus.setMessage("Ready");
        /**
         * [sdk-initialization-flow] recieved initialization success event
         * sending event to channel class
         */
        synchronized (statusListenerListMutex) {
            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
                statusEvents.onInitializationSuccess();
            }
        }

        VoiceAppLogger.debug(TAG, "End: onStatusChange");

    }

    @Override
    public void onDestroyMediaSession() {
        VoiceAppLogger.debug(TAG, "Start: onDestroyMediaSession");

        synchronized (statusListenerListMutex) {
            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
                statusEvents.onDestroyMediaSession();
            }
        }

        VoiceAppLogger.debug(TAG, "End: onDestroyMediaSession");

    }

    @Override
    public void onDeInitialized() {
        VoiceAppLogger.debug(TAG, "Start: onDeInitialized");
        synchronized (statusListenerListMutex) {
            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
                statusEvents.onDeInitialization();
            }
        }
        VoiceAppLogger.debug(TAG, "Exit: onDeInitialized");
    }

    /**
     * handle the incoming event from exotel client SDK
     * when SDK is not initialized
     */
    @Override
    public void onInitializationFailure(ExotelVoiceError error) {

        VoiceAppLogger.debug(TAG, "Start: onInitializationFailure");
        initializationInProgress = false;
        initializationErrorMessage = error.getErrorMessage();
        VoiceAppLogger.error(TAG, "Failed to initialize voip SDK, error is: "
                + error.getErrorMessage());

        voiceAppStatus.setState(VoiceAppState.STATUS_INITIALIZATION_FAILURE);
        voiceAppStatus.setMessage(error.getErrorMessage());
        /**
         * [sdk-initialization-flow] recieved initialization failure event
         * sending event to channel class
         */
        synchronized (statusListenerListMutex) {
            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
                statusEvents.onInitializationFailure(error);
            }
        }

        VoiceAppLogger.debug(TAG, "End: onInitializationFailure");
    }

    /**
     * handle the incoming log event from exotel client SDK
     */
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

    public void uploadLogs(Date startDate, Date endDate, String description) throws Exception {
        VoiceAppLogger.debug(TAG, "uploadLogs: startDate: " + startDate + " EndDate: " + endDate);
        exotelVoiceClient.uploadLogs(startDate, endDate, description);
    }

    public void onUploadLogSuccess() {
        for (LogUploadEvents logUploadEvents : logUploadEventsList) {
            logUploadEvents.onUploadLogSuccess();
        }
    }
    public void onUploadLogFailure(ExotelVoiceError error) {
        for (LogUploadEvents logUploadEvents : logUploadEventsList) {
            logUploadEvents.onUploadLogFailure(error);
        }
    }

    /**
     * handle the incoming authentication failure event from exotel client SDK
     */
    @Override
    public void onAuthenticationFailure(ExotelVoiceError exotelVoiceError) {
        VoiceAppLogger.error(TAG, "Authentication Failure");
        synchronized (statusListenerListMutex) {
            for (VoiceAppStatusEvents statusEvents : voiceAppStatusListenerList) {
                statusEvents.onAuthFailure();
            }
        }
    }


    Boolean isRefreshTokenValid(String regAuthToken) {
        VoiceAppLogger.debug(TAG, "isRefreshTokenValid: " + regAuthToken);

        try {
            JSONObject jsonObject = new JSONObject(regAuthToken);
            String refreshToken = jsonObject.getString("refresh_token");
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: " + refreshToken);

            String tokenParts[] = refreshToken.split("\\.");
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: " + tokenParts);

            String tokenPayload = tokenParts[1];
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: Token Payload " + tokenPayload);

            String tokenString = new String(Base64.decode(tokenPayload, Base64.URL_SAFE));
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: Token String " + tokenString);
            JSONObject regAuthTokenJson = new JSONObject(tokenString);
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: JSON " + regAuthTokenJson.toString());
            long expTime = regAuthTokenJson.getInt("exp");
            VoiceAppLogger.debug(TAG, "isRefreshTokenValid: Token Expiry " + expTime);

            long curTime = System.currentTimeMillis();
            if (curTime > expTime) {
                VoiceAppLogger.debug(TAG, "Refresh Token Expired");
                return false;
            }
        } catch (JSONException | NullPointerException e) {
            VoiceAppLogger.error(TAG, "Unable to decode refresh token " + e.getMessage());
            return false;
        }

        return true;
    }

    /* Implementation of ExotelVoipCallListemer events */

    /**
     * handle incoming call events from exotel client
     * @param call
     */
    @Override
    public void onIncomingCall(Call call) {
        VoiceAppLogger.debug(TAG, "Incoming call Received, callId: " + call.getCallDetails().getCallId());
        tonePlayback.startTone();
        mCall = call;
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onCallIncoming(call);
        }
    }

    @Override
    public void onCallInitiated(Call call) {
        VoiceAppLogger.debug(TAG, "on Call initiated");
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onCallInitiated(call);
        }
        mCall = call;
        VoiceAppLogger.debug(TAG, "End: onCallInitiated");
    }

    /**
     * handle call ringing event from exotel client
     * @param call
     */
    @Override
    public void onCallRinging(Call call) {
        VoiceAppLogger.debug(TAG, "on call ringing event is Sample Application Service");

        ringingStartTime = System.currentTimeMillis() / 1000L;
        mCall = call;
        /**
         * [sdk-calling-flow] recieved ringing event from exotel client
         * when dialer number is ringing
         * sending call ringing event to channel class
         */
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onCallRinging(call);
        }
        VoiceAppLogger.debug(TAG, "End: onCallRinging");
    }

    /**
     * handle call establish event from exotel client
     * @param call
     */
    @Override
    public void onCallEstablished(Call call) {
        VoiceAppLogger.debug(TAG, "Call Estabslished");
        ringingStartTime = 0;
        mCall = call;
        /**
         * [sdk-calling-flow] recieved call connected event from exotel client
         * when dialer number is connected
         * sending call establish event to channel class
         */
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onCallEstablished(call);
        }
    }

    /**
     * handle call ended event from exotel client
     * @param call
     */
    @Override
    public void onCallEnded(Call call) {
        VoiceAppLogger.debug(TAG, "Call Ended, call ID: " + call.getCallDetails().getCallId()
                + " Session ID: " + call.getCallDetails().getSessionId() + "Call end reason: " + call.getCallDetails().getCallEndReason());
        ringingStartTime = 0;

        tonePlayback.stopTone();

        mCall = null;
        mPreviousCall = call;
        /**
         * [sdk-calling-flow] recieved call disconnected event from exotel client
         * when dialer number is disconnected
         * sending call ended event to channel class
         */
        for (CallEvents callEvents : callEventListenerList) {
            VoiceAppLogger.debug(TAG, "Sending call ended event to: " + callEvents);
            callEvents.onCallEnded(call);
        }

        if (CallEndReason.BUSY == call.getCallDetails().getCallEndReason()) {
            VoiceAppLogger.debug(TAG, "Playing busy tone");
            tonePlayback.playBusyTone();
        } else if (CallEndReason.TIMEOUT == call.getCallDetails().getCallEndReason()) {
            VoiceAppLogger.debug(TAG, "Playing reorder tone");
            tonePlayback.playReorderTone();
        }

        /* Insert into SqlLite DB for recent call Tabs */
        CallType callType = CallType.INCOMING;
        String destination;
        destination = call.getCallDetails().getRemoteId();

        if(CallDirection.INCOMING == call.getCallDetails().getCallDirection() &&
                CallEndReason.TIMEOUT == call.getCallDetails().getCallEndReason()){
            callType = CallType.MISSED;
        } else if (CallDirection.INCOMING == call.getCallDetails().getCallDirection()) {
            callType = CallType.INCOMING;
        } else if (CallDirection.OUTGOING == call.getCallDetails().getCallDirection()) {
            callType = CallType.OUTGOING;
            SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
            destination = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.LAST_DIALLED_NO.toString());
        }
        Date date = new Date(call.getCallDetails().getCallStartedTime() * 1000);

        databaseHelper.insertData(destination, date, callType);
    }

    @Override
    public void onMissedCall(String remoteId, Date time) {
        VoiceAppLogger.debug(TAG, "Missed call, remoteId: " + remoteId + " Time: " + time);

        VoiceAppLogger.debug(TAG, "Size of call event listener is: " + callEventListenerList.size());
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onMissedCall(remoteId, time);
        }

        VoiceAppLogger.debug(TAG, "Playing waiting tone");
        tonePlayback.playWaitingTone();

        /* Add to SqlLite DB for Recent Call Fragment */
        databaseHelper.insertData(remoteId, time, CallType.MISSED);
    }

    @Override
    public void onMediaDisrupted(Call call) {
        VoiceAppLogger.debug(TAG, "Call media disrupted, Call Id: "+call.getCallDetails().getCallId());
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onMediaDisrupted(call);
        }
        mCall = call;
    }

    @Override
    public void onRenewingMedia(Call call) {
        VoiceAppLogger.debug(TAG, "Call media renewing, Call Id: "+call.getCallDetails().getCallId());
        for (CallEvents callEvents : callEventListenerList) {
            callEvents.onRenewingMedia(call);
        }
        mCall = call;
    }

    void processPushNotification(Map<String, String> remoteData) {

        VoiceAppLogger.debug(TAG,"Got a push notification!!");
        VoiceAppLogger.debug(TAG,"Printing all the key value pairs in the hashmap");
        for (String entry : remoteData.keySet()) {
            String value = remoteData.get(entry);
            VoiceAppLogger.debug(TAG,"Now printing values");
            VoiceAppLogger.debug(TAG,"Key is: "+entry);
            VoiceAppLogger.debug(TAG,"Value is: "+remoteData.get(entry));


        }
        VoiceAppLogger.debug(TAG,"Trying to decode the JSON");


        final ObjectMapper mapper = new ObjectMapper();
        final PushNotificationData pushNotificationData = mapper.convertValue(remoteData,
                PushNotificationData.class);
        VoiceAppLogger.debug(TAG,"Version is: "+pushNotificationData.getPayloadVersion());
        VoiceAppLogger.debug(TAG,"Payload is: "+pushNotificationData.getPayload());
        VoiceAppLogger.debug(TAG,"User ID is: "+pushNotificationData.getSubscriberName());

        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        String subscriberName = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.USER_NAME.toString());
        if(!subscriberName.equals(pushNotificationData.getSubscriberName())) {
            VoiceAppLogger.error(TAG,"User ID in push notification: "
                    + pushNotificationData.getSubscriberName() + " Current User Id: "+subscriberName);
            return;
        }

        /* Check for Logged In Status */
        boolean isLoggedIn = sharedPreferencesHelper.getBoolean(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString());
        if(!isLoggedIn) {
            VoiceAppLogger.error(TAG,"Not logged in, blocking the call: ");
            return;
        }
        VoiceAppLogger.debug(TAG,"Creating intent for service");
         pushNotificationPayloadVersion =pushNotificationData.getPayloadVersion();
         pushNotificationPayload = pushNotificationData.getPayload();

        subscriberName = pushNotificationData.getSubscriberName();
        relayPushNotification =true;


        String hostname = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.SDK_HOSTNAME.toString());
        String subscriberToken = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.SUBSCRIBER_TOKEN.toString());
        String accountSid = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString());
        displayName = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.DISPLAY_NAME.toString());

//        VoiceAppLogger.debug(TAG,"Service is NULL");
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            intent.putExtra("foreground",true);
//            startForegroundService(intent);
//
//        } else {
//            startService(intent);
//        }
        VoiceAppLogger.debug(TAG,"Calling bind Service");

        if (relayPushNotification) {
            VoiceAppLogger.debug(TAG, "Payload Version: " + pushNotificationPayloadVersion
                    + "payload: " + pushNotificationPayload + " userId: " + subscriberName);
            try {
                initialize(hostname, subscriberName, accountSid, subscriberToken, displayName);
            } catch (Exception e) {
                VoiceAppLogger.error(TAG, "Exception in initialization for push notification");
            }
            VoiceAppLogger.debug(TAG, "Before sendPushNotifcationData");
            sendPushNotificationData(pushNotificationPayload, pushNotificationPayloadVersion, subscriberName);
        }

    }


    public void sendPushNotificationData(String payload, String payloadVersion, String userId) {
        VoiceAppLogger.debug(TAG, "Sending push notification data function");
        Map<String, String> pushNotificationData = new HashMap<>();
        pushNotificationData.put("payload", payload);
        pushNotificationData.put("payloadVersion", payloadVersion);
        if (null != exotelVoiceClient) {
            try {
                if (!exotelVoiceClient.relaySessionData(pushNotificationData)) {
                    makeServiceBackground();
                }
            } catch (Exception e) {
                VoiceAppLogger.error(TAG, "Exception in relaySessionData: " + e.getMessage());
                makeServiceBackground();
            }

        } else {
            VoiceAppLogger.error(TAG, "Initialize has not been called before relaySessionData");

        }
    }

    public Boolean relaySessionData(Map<String, String> pushNotificationData) throws Exception {
        return exotelVoiceClient.relaySessionData(pushNotificationData);
    }

    public void makeServiceBackground() {

        if (null == mCall) {
            VoiceAppLogger.debug(TAG, "Removing the service from foreground");

//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                stopForeground(STOP_FOREGROUND_REMOVE);
//            } else {
//                stopForeground(true);
//            }
        }

    }

}

