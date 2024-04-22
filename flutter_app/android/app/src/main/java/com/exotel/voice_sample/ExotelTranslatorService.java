package com.exotel.voice_sample;

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

public class ExotelTranslatorService extends Service implements ExotelVoiceClientEventListener, CallListener {

    private static final String TAG = "ExotelTranslatorService";
    private final IBinder binder = new LocalBinder();
    private MethodChannel channel;
    private ExotelVoiceClient exotelVoiceClient;
    private String mSDKHostName;
    private String mAccountSid;
    private String mUserName;
    private String mSubsriberToken;
    private String mDisplayName;
    private CallController callController;
    private Call mCall;
    private Call mPreviousCall;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    private Context context;

    public ExotelTranslatorService() {
    }

    void setContext (Context context) {
        this.context = context;
    }

    @Override
    public IBinder onBind(Intent intent) {
        VoiceAppLogger.debug(TAG, "onBind for sample service");
        return binder;
    }
    public class LocalBinder extends Binder {
        ExotelTranslatorService getService() {
            return ExotelTranslatorService.this;
        }
    }



    void registerPlatformChannel(MethodChannel methodChannel) {
        // Channel is created for communication b/w flutter and native
        channel = methodChannel;
        // handle messages from flutter to android native
        channel.setMethodCallHandler(
                (call, result) -> {
                    System.out.println("Entered in Native Android");
                    switch (call.method) {
                        case "get-device-id":
                            String androidId = Settings.Secure.getString(this.getApplicationContext().getContentResolver(), Settings.Secure.ANDROID_ID);
                            result.success(androidId);
                            break;
                        case "initialize":
                            mSDKHostName = call.argument("host_name");
                            mAccountSid = call.argument("account_sid");
                            mUserName = call.argument("subscriber_name");
                            mSubsriberToken = call.argument("subscriber_token");
                            mDisplayName = call.argument("display_name");
                            try {
                                initialize(mSDKHostName,mUserName,mAccountSid,mSubsriberToken,mDisplayName);
                            } catch (Exception e) {
                                result.error(ErrorType.INTERNAL_ERROR.name(),e.getMessage(),null );
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
                                mCall = dial(dialNumber, contextMessage);
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
                                sendDtmf(digitChar);
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
                            try {
                                Boolean relaySucces = relaySessionData(data);
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
                exotelVoiceClient.initialize(this.getApplicationContext(), hostname, subscriberName, displayName, accountSid, subscriberToken);
            } catch (Exception e) {
                VoiceAppLogger.error(TAG, "Exception in SDK initialization: " + e.getMessage());
                throw new Exception(e.getMessage());
            }
        }
        callController = exotelVoiceClient.getCallController();
        callController.setCallListener(this);
        VoiceAppLogger.debug(TAG, "Returning from initialize with params in sample service");
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

    private Call dial(String destination, String message) throws Exception {
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
        uiThreadHandler.post(()->{
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("version", message);
            channel.invokeMethod(MethodChannelInvokeMethod.ON_VERSION_DETAILS, arguments);
        });
    return message;
    }

    public void uploadLogs(Date startDate, Date endDate, String description) throws Exception {
        VoiceAppLogger.debug(TAG, "uploadLogs: startDate: " + startDate + " EndDate: " + endDate);
        exotelVoiceClient.uploadLogs(startDate, endDate, description);
    }
    private boolean relaySessionData(Map<String, String> data) throws Exception {
        try {
            return exotelVoiceClient.relaySessionData(data);
        } catch (Exception e) {
            VoiceAppLogger.error(TAG, "Exception in relaySessionData: " + e.getMessage());
            throw new Exception("Exception in relaySessionData");
        }
    }

    @Override
    public void onIncomingCall(Call call) {
        mCall = call;
        String callId = call.getCallDetails().getCallId();
        String destination = call.getCallDetails().getRemoteId();
        VoiceAppLogger.debug(TAG, "in onCallIncoming(), callId = " + callId + "destination = " +destination);
        uiThreadHandler.post(()->{
            HashMap<String, Object> arguments = new HashMap<>();
            arguments.put("callId", callId);
            arguments.put("destination", destination);
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INCOMING_CALL, arguments);
        });
    }

    @Override
    public void onCallInitiated(Call call) {
        mCall = call;
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_INITIATED, null);
        });
    }

    @Override
    public void onCallRinging(Call call) {
        mCall = call;
        VoiceAppLogger.debug(TAG, "in onCallRinging(), ExotelTranslatorService");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_RINGING, null);
        });
    }

    @Override
    public void onCallEstablished(Call call) {
        mCall = call;
        uiThreadHandler.post(()-> {
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_ESTABLISHED, null);
        });
    }

    @Override
    public void onCallEnded(Call call) {
        mCall = null;
        mPreviousCall = call;
        uiThreadHandler.post(()-> {
            HashMap<String, String> arguments = new HashMap<>();
            arguments.put("direction", call.getCallDetails().getCallDirection().toString());
            arguments.put("end-reason", call.getCallDetails().getCallEndReason().toString());
            channel.invokeMethod(MethodChannelInvokeMethod.ON_CALL_ENDED, null);
        });


    }

    @Override
    public void onMissedCall(String s, Date date) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_MISSED_CALL, null);
        });
    }

    @Override
    public void onMediaDisrupted(Call call) {
        mCall = call;
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_MEDIA_DISTRUPTED, null);
        });
    }

    @Override
    public void onRenewingMedia(Call call) {
        mCall = call;
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_RENEWING_MEDIA, null);
        });
    }

    @Override
    public void onInitializationSuccess() {
        VoiceAppLogger.debug(TAG, "Enter onInitializationSuccess()");
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_SUCCESS,null);
        });
    }

    @Override
    public void onInitializationFailure(ExotelVoiceError exotelVoiceError) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_INITIALIZATION_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
        });
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
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_SUCCESS,null);
        });
    }

    @Override
    public void onUploadLogFailure(ExotelVoiceError exotelVoiceError) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_UPLOAD_LOG_FAILURE,createResponse(exotelVoiceError.getErrorMessage()));
        });
    }

    @Override
    public void onAuthenticationFailure(ExotelVoiceError exotelVoiceError) {
        uiThreadHandler.post(()->{
            channel.invokeMethod(MethodChannelInvokeMethod.ON_AUTHENTICATION_FAILURE,createResponse("Authentication failure"));
        });
    }
    Map<String, String> createResponse(String data){
        Map<String,String> result = new HashMap<>();
        result.put("data",data);
        return result;
    }
}