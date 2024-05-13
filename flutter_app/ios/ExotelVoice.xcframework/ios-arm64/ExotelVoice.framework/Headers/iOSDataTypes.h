//
//  iOSDataTypes.h
//  Cloudonix Mobile SDK API data types
//

//
//  Authors:
//    - Arik Halperin, 2015-10-18
//    - Igor Nazarov, 2017-07-06
//    - Oded Arbel, 2020-06-16
//
//  Copyright © 2015 GreenfieldTech 2015 Ltd. All rights reserved.
//  Copyright © 2018 Cloudonix Ltd. All rights reserved.
//  Copyright © 2019 Cloudonix Inc. All rights reserved.
//

#ifndef __cloudonix__iOSDataTypes__
#define __cloudonix__iOSDataTypes__

#import <Foundation/Foundation.h>

typedef enum {
	/**Session disconnected event*/
	IOS_CallState_Disconnected = 0,
	/**INVITE is received event*/
	IOS_CallState_Incoming = 1,
	/**INVITE is sent event*/
	IOS_CallState_Calling = 2,
	/**180/183 received event*/
	IOS_CallState_Ringing = 3,
	/**ACK is sent/received event*/
	IOS_CallState_Confirmed = 4,
	/**Call placed on hold by me event*/
	IOS_CallState_LocalHold = 5,
	/**Call placed on hold by remote party event*/
	IOS_CallState_RemoteHold = 6,
	/**Call placed on hold by me and the remote party event*/
	IOS_CallState_LocalRemoteHold = 7,
	/**2xx is sent/received event*/
	IOS_CallState_Connecting = 8,
	/**Response with To tag event*/
	IOS_CallState_Early = 9,
	/**Not applicable*/
	IOS_CallState_Starting = 10,
	/**Media is flowing in both directions event*/
	IOS_CallState_MediaActive = 11,
	/**Not applicable*/
	IOS_CallState_DisconnectedMediaChanged = 12,
	IOS_CallState_DisconnectedDueToBusy = 13,
	IOS_CallState_DisconnectedDueToNetworkChange = 14,
	IOS_CallState_DisconnectedDueToNoMedia = 15,
	IOS_CallState_DisconnectedDueToTimeout = 16,
	IOS_CallState_Media_Disrupted = 17,
	IOS_CallState_Renewing_Media = 18,
} CloudonixCallState_e;

#define iOSCallState_e CloudonixCallState_e

typedef enum {
	IOS_Status_IDLE,
	IOS_Status_STARTING,
	IOS_Status_ACTIVE_CALL,
	IOS_Status_WAITING_FOR_USER,
	IOS_Status_CALLING,
	IOS_Status_CONNECTING,
	IOS_Status_RINGING,
	IOS_Status_LOCAL_HOLD,
	IOS_Status_REMOTE_HOLD,
	IOS_Status_LOCAL_REMOTE_HOLD,
	IOS_Status_WAITING_FOR_HOLD_RESPONSE,
	IOS_Status_RENEWING_WAITING_FOR_HOLD,
	IOS_Status_RENEWING_MEDIA,
	IOS_Status_WAIT_FOR_DISCONNECT,
} CloudonixCallStatus_e;

typedef enum{
	IOS_TRANSPORT_TYPE_UDP = 0,
	IOS_TRANSPORT_TYPE_TCP = 1,
	IOS_TRANSPORT_TYPE_TLS = 2,
} CloudonixTransportType;

#define iOSTransportType CloudonixTransportType

typedef enum {
	IOS_WORKFLOW_TYPE_AUTODETECT = 0,
	IOS_WORKFLOW_TYPE_REGISTRATION = 1,
	IOS_WORKFLOW_TYPE_REGISTRATION_FREE = 2,
	IOS_WORKFLOW_TYPE_REGISTRATION_LESS = 3
} CloudonixWorkflowType;

#define iOSWorkflowType CloudonixWorkflowType

@interface CloudonixRegistrationData : NSObject

@property NSString *serverUrl;
@property NSString *username;
@property NSString *password;
@property int port;
@property bool useDnsSrv;
@property NSString *displayName;
@property CloudonixTransportType transportType;
@property NSString *domain;
@property CloudonixWorkflowType workflow;

@end

#define iOSRegistrationData CloudonixRegistrationData

@interface CloudonixChannelStatistics : NSObject

@property int averageJitterMs;
@property int maxJitterMs;
@property int fractionLost;
@property int cumulativeLost;
@property int extendedMax;
@property int jitterSamples;
@property int jitterBufferMs;
@property int preferredJitterBufferMs;
@property int rttMs;
@property int bytesSent;
@property int packetsSent;
@property int bytesReceived;
@property int packetsReceived;
@property NSString * codecName;
@property float MOS;
@property int remoteFractionLoss;
@property int last_SR_timestamp;
@property int audioBitRate;
@property long seconds;
@property long duration;
@property long noPacketsTime;
@property float averageLatency;
@property float latencyJitter;
@property float currentPacketLossRate;
@property int mediaWaitingTimeMs;

@end

#define iOSChannelStatistics CloudonixChannelStatistics

typedef enum {
	/**Registered successfully*/
	IOS_REGISTRATION_SUCCESS = 0,
	/**Credentials required*/
	IOS_REGISTRATION_ERROR_CREDENTIALS = 1,
	/*Registration attempt timed out*/
	IOS_REGISTRATION_ERROR_TIMEOUT = 2,
	/**Unregistered after successful registration*/
	IOS_REGISTRATION_UNREGISTERED = 3,
	/**TBD */
	IOS_REGISTRATION_RESOLVE_ERROR = 4,
	IOS_REGISTRATION_SERVICE_UNAVAILABLE = 5,
} CloudonixRegistrationState_e;

#define iOSRegistrationState_e CloudonixRegistrationState_e

typedef enum {
	IOS_LOG_LEVEL_OFF = 0,
	IOS_LOG_LEVEL_ERROR = 1,
	IOS_LOG_LEVEL_WARNING = 2,
	IOS_LOG_LEVEL_DEBUG = 3,
	IOS_LOG_LEVEL_INFO = 4,
	IOS_LOG_LEVEL_VERBOSE = 5,
	IOS_LOG_LEVEL_ALL = 6,
} CloudonixLogLevel_e;

#define iOSLogLevel_e CloudonixLogLevel_e;

typedef enum {
	IOS_LICENSE_SUCCESS = 0,
	IOS_LICENSE_INVALID_KEY_ERROR = 1,
	IOS_LICENSE_EXPIRED_ERROR = 2,
	IOS_LICENSE_KEY_REVOKED_ERROR = 3,
	IOS_LICENSE_COULD_NOT_BE_VERIFIED_ERROR = 4,
} CloudonixLicenseState_e;

#define iOSLicenseState_e CloudonixLicenseState_e

/*!
 @typedef IPVersion

 @brief Represents a version of Internet Protocol: IPv4 or IPv6.
 */
typedef NS_ENUM(NSInteger, IPVersion)
{
    IPvNone,
    IPv4,
    IPv6
};

/*!
 @typedef NATType

 @brief This enumeration describes the NAT types, as specified by RFC 3489 Section 5, NAT Variations.
 */
typedef NS_ENUM(NSInteger, NATType)
{
    NATTypeUnknown,
    NATTypeErrUnknown,
    NATTypeOpen,
    NATTypeBlocked,
    NATTypeSymmenricUDP,
    NATTypeFullCone,
    NATTypeSymmetric,
    NATTypeRestricted,
    NATTypePortRestricted
};

@interface  VoipCall : NSObject

@property (nonatomic,strong) NSString * sipCallId;
@property (nonatomic,strong) NSString * key;
@property (nonatomic,strong) NSString * url;
@property (nonatomic) CloudonixCallStatus_e callStatus;
@property (nonatomic) CloudonixCallState_e state;
@property (nonatomic) long startTime;
@property (nonatomic) bool isMuted;

- (bool)isActive;

@end

#endif // __cloudonix__iOSDataTypes__
