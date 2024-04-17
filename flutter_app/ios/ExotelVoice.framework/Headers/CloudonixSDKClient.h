//
//  CloudonixSDKClient.h
//  Cloudonix Mobile SDK API
//

//
//  Authors:
//    - Arik Halperin, 2015-10-18
//    - Oded Arbel, 2019-12-16
//
//  Copyright © 2015 GreenfieldTech 2015 Ltd. All rights reserved.
//  Copyright © 2018 Cloudonix Ltd. All rights reserved.
//  Copyright © 2019 Cloudonix Inc. All rights reserved.
//

#ifndef __cloudonix__CloudonixSDKClient__
#define __cloudonix__CloudonixSDKClient__

#import "iOSDataTypes.h"
#import "AudioSessionManager.h"

/*!
 @protocol CloudonixSDKClientListener

 @brief The CloudonixSDKClientListener protocol

 It's a protocol used to receive different events from the CloudonixSDKClient instance.
 */
@protocol CloudonixSDKClientListener<NSObject>

@optional

/** Audio driver was released. */
- (void)onDestroyMediaSession;

/** VoIP manager initiated successfully. */
- (void)onSipStarted;

/** VoIP manager initiation failed. */
- (void)onSipStartFailed;

/** VoIP engine de-initialized. */
- (void)onSipStopped;

/** Registration state changed. */
- (void)onRegisterState:(CloudonixRegistrationState_e)result expiry:(int)expiry;

/** Call state changed. */
- (void)onCallState:(NSString*)callId callState:(CloudonixCallState_e)callState contactUrl:(NSString*)contactUrl;

/** Log message from native code. */
- (void)onLog:(int)level message:(NSString*)message;

/** Network is not reachable. */
- (void)onNetworkLost;

/** Network has changed. */
- (void)onNetworkChanged;

/** Network is reachable again. */
- (void)onNetworkRegained;

/** NAT type detected. */
- (void)onNATTypeDetected:(NATType)detectedNATType;

@end

typedef void(^CloudonixSDKInitializationCompletionBlock)(BOOL success, NSError* error);

/*!
 @class CloudonixSDKClient

 @brief The CloudonixSDKClient class

 @discussion This class was designed and implemented as a native iOS wrapper around all cross-platform VoIP features.
 */

@interface CloudonixSDKClient : NSObject

/** Current IP address of an iOS device. */
@property (nonatomic, strong) NSString* currentIp;

/** Current IP version of an iOS device. */
@property (nonatomic, readonly) IPVersion ipVersion;

/** VoIP manager was initialized or not . */
@property (nonatomic, readonly) BOOL isStarted;

@property (nonatomic, readonly) AudioSessionManager* audioSession;

/*!
 @brief Access point for CloudonixSDKClient singleton object.

 @return CloudonixSDKClient A global instance of Cloudonix SDK iOS wrapper.
 */
+ (instancetype)sharedInstance;

/*!
 @brief Shutdown the SDK. Can be useful when the app is about to terminate.
 */
-(void)shutdown;

/*!
 @brief Application calls SDK init and passes license key text (base64 encoded crypt text). Cloudonix SDK initializes required modules, such as Reachability and Audio Routing

 */
- (void)initializeWithKey:(NSString*)licenseKey completion:(CloudonixSDKInitializationCompletionBlock)completion;

/*!
 @brief Adds a listener for SDK events.

 @param listener Application listener for SDK events like registration state change and call state change.
 */
- (void)addListener:(id<CloudonixSDKClientListener>)listener;

/*!
 @brief Stop listening to events.

 @param listener Application listener for SDK events.
 */
- (void)removeListener:(id<CloudonixSDKClientListener>)listener;

/*!
 @brief De-initialize VoIP manager.
 */
- (void)stop;

/*!
 @brief Controls a level of logs produces by the SDK.

 @param level A level of logging. Appropriate values are: 0 (off), 1 (error), 2 (warning), 3 (debug), 4 (info), 5 (verbose), 6 (all).
 */
- (void)setLogLevel:(int)level;

/*!
 @brief Configure the account connection details and start the SIP stack.

 @param regData Contains information about server, user, password, etc.
 */
- (void)setConfiguration:(CloudonixRegistrationData*)regData;

/*!
 @brief Start communicating with the server.
 */
- (void)registerAccount;

/*!
 @brief Indicates if an account is registered.

 @return bool True = registered, False = unregistered.
 */
- (bool)isRegistered;

/*!
 @brief Register with SIP server. SIP server and account information are defined in the CloudonixRegistrationData, which is set in setConfiguration().
 @deprecated SDK handles this automatically
 */
- (void)reregister;

/*!
 @brief Unregister from SIP server.
 */
- (void)unregister;

/*!
 @brief Call another endpoint defined by the contactUrl.

 @param contactUrl The information about the remote party being called. It could be a SIP URI or a phone number.

 @return BOOL Indicates if it is possible to make a call. Will return false if the contactUrl is empty, user is not registered etc.
 */
- (BOOL)dial:(NSString*)contactUrl;

/*!
 @brief Call another endpoint defined by the contactUrl.

 @param contactUrl The information about the remote party being called. It could be a SIP URI or a phone number.
 @param headerList Contains key-value pairs with sip header names and their values.

 @return BOOL Indicates if it is possible to make a call. Will return false if the contactUrl is empty, user is not registered etc.
 */
- (BOOL)dial:(NSString*)contactUrl headerList:(NSDictionary*)headerList;

/*!
 @brief Registration-Free dialing.

 @param contactUrl The information about the remote party being called. It could be a SIP URI or a phone number.
 @param sessionId Cloudonix session identifier.
 */
- (void)dialRegistrationFree:(NSString*)contactUrl session:(NSString*)sessionId;

/*!
 @brief Registration-Free dialing.

 @param contactUrl The information about the remote party being called. It could be a SIP URI or a phone number.
 @param sessionId Cloudonix session identifier.
 @param headerList Contains key-value pairs with sip header names and their values.
 */
- (void)dialRegistrationFree:(NSString*)contactUrl session:(NSString*)sessionId headerList:(NSDictionary*)headers;

/*!
 @brief Terminate a specific line.

 @param callId A unique identifier of a connected line.
 */
- (void)hangup:(NSString*)callId;

/*!
 @brief Terminate a specific line.

 @param url A url of a subscriber.
 */
- (void)hangupByURL:(NSString*)url;

/*!
 @brief Hold or unhold a specific connected line.

 @param callId A unique identifier of a connected line.
 @param enable Action to perform. True = hold, False = unhold.
 */
- (void)localHold:(NSString*)callId enable:(bool)enable;

/*!
 @brief Mute the currently active line.

 @param enable True = mute, False = unmute.
 */
- (void)mute:(bool)enable;

/*!
 @brief Send a DTMF in the current active line.

 @param callId A unique identifier of a connected line.
 @param digit The DTMF character to send.
 */
- (void)dtmf:(NSString*)callId digit:(char)digit;

/*!
 @brief Accept an incoming call on a specific line.

 @param callId A unique identifier of a connected line.
 */
- (void)answer:(NSString*)callId;

/*!
 @brief Reject an incoming call on a specific line.

 @param callId A unique identifier of a connected line.
 */
- (void)reject:(NSString*)callId;

/*!
 @brief Information about the media channel.

 @param callId A unique identifier of a connected line.

 @return CloudonixChannelStatistics* An active call VoIP statistics. Contains information about media quality as well as other quality indicators.
 */
- (CloudonixChannelStatistics*)getStatistics:(NSString*)callId;

/*!
 @brief Get the current state of a specific line.

 @param callId A unique identifier of a connected line.

 @return NSString* The state of a call.
 */
- (NSString*)getCallState:(NSString*)callId;

/*!
 * @brief Get the url of subscriber for a specific line.
 * 
 * @param callId A unique identifier of a connected line.
 * 
 * @return NSString* The url of a subscriber.
 */
- (NSString*)getCallUrl:(NSString*)callId;

/*!
 * @brief Returns the time the call was started.
 * 
 * @param callId A unique identifier of a connected line.
 * 
 * @return long The start time of a call in UNIX epoch seconds
 */
- (long)getCallStartTime:(NSString*)callId;

/*!
 @brief Get a unique identifier for a specific line.

 @param index The index of a soecific line in an ordered array of all lines.

 @return NSString* The id of a call.
 @deprecated use getCalls instead
 */
- (NSString*)getCallIdForIndex:(int)index;

/*!
 @brief Get a number of active VoIP calls.

 @return int Number of calls.
 */
- (int)getNumberOfCalls;

/*!
 @brief Get a list of active VoIP calls.

 @return NSArray* An array of calls.
 */
- (NSArray*)getCalls;

/*!
 @brief Configures specific parameters in Cloudonix SDK that determines the behaviour of the SDK. The parameters are passed as a key-value pair.

 @param key Defines the parameter to set. The types of keys available are detailed below.
 @param value Defines the value to set for a specific key.

 Available keys for configuration are:
 key                    type of value
 ------------------------------------

 TSX_TIMER                int    (default: 5000)
 ENABLE_ICE               bool   (default: true)
 USER_AGENT               string (default: "CloudonixSDK/VERSION")
 LOG_LEVEL                int    (default: 6)
 WEBRTC_LOG_LEVEL         int    (unused)
 PLAYBACK_LATENCY         int    (default: 140)
 CAPTURE_LATENCY          int    (default: 100)
 ENABLE_TURN              bool   (default: false)
 TURN_SERVER              string (default: none)
 TURN_PORT                int    (default: 3478)
 USE_TCP_FOR_TURN         bool   (default: false)
 TURN_REALM               string (default: "cloudonix")
 TURN_USER                string (default: none)
 TURN_PASSWORD            string (default: none)
 KEEP_ALIVE_INTERVAL      int    (default: 300)
 REGISTRATION_TIMEOUT     int    (default: 300)
 ENABLE_NAT               bool   (default: true)
 USE_OPUS                 bool   (default: true)
 USE_G722                 bool   (default: false)
 USE_G711                 bool   (default: false)
 USE_ILBC                 bool   (default: false)
 MAX_RATE                 int    (default: 24000 - only for Opus)
 MIN_RATE                 int    (default: 8000 - only for Opus)
 USE_AGC                  bool   (default: true)
 FORCE_NS                 int    (default: -1)
 NS_TYPE                  string (default: "DEFAULT" - select best value for platform)
 EC_TYPE                  string (default: "DEFAULT" - select best value for platform)
 ALLOW_MULTIPLE_CALLS     bool   (default: true)
 DISABLE_REGISTRATION_REFRESH bool (default: false)
 NO_MEDIA_PERIOD          int    (default: 30)
 ENABLE_STUN              bool   (default: false)
 STUN_SERVER              string[] (default: no servers) 
 DISABLE_SECURE_SIPS      bool   (default: true)
 DISABLE_PLATFORM_LOGS    bool   (default: false)
 TLS_NEGOTIATION_TIMEOUT  int    (default: 1500)
 SIP_NEGOTIATION_TIMEOUT  int    (default: 5000)
 UNREGISTER_ACCOUNT_ON_NETWORK_ERROR bool (default: false)
 LOG_CALL_MEDIA_STATISTICS bool  (default: false)
 MEDIA_RESET_TIMEOUT      unsigned (default: 4)
 NAME_SERVER              string[] (default: Google's public DNS servers)
 */
- (void)setConfig:(NSString*)key value:(NSString*)value;

/*!
 @brief Re-initialize VoIP manager with new configuration. Configuration changes will only take effect after commitConfig is called.
 */
- (void)commitConfig;

/*!
 @brief Indicates if there is a need to log call statistics.

 @param enable True = log statistics, False = otherwise.
 */
- (void)dumpStatisticsToLog:(bool)enable;

/*!
 @brief Get current SDK version number

 @param enable True = log statistics, False = otherwise.
 */
- (NSString*)sdkVersion;

@end

@compatibility_alias iOSWrapper CloudonixSDKClient;
#define iOSWrapperListener CloudonixSDKClientListener;

#endif // __cloudonix__CloudonixSDKClient__
