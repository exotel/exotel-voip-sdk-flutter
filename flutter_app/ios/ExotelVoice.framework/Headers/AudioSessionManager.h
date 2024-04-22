//
//  AudioSessionManager.h
//
//  This module routes audio output depending on device availability using the
//  following priorities: bluetooth, wired headset, speaker.
//
//  It also notifies interested listeners of audio change events (optional).
//
//  Copyright 2011 Jawbone Inc.
//  Partial Copyright 2019 Cloudonix Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString* const kAudioSessionManagerDevice_Headset;
extern NSString* const kAudioSessionManagerDevice_Bluetooth;
extern NSString* const kAudioSessionManagerDevice_Phone;
extern NSString* const kAudioSessionManagerDevice_Speaker;

/** 
 Registered listeners will be notified when a route change has occurred. Do not use if you control audio route.
 */
extern NSString *const AudioSessionManagerRouteChangeNotification;

/**
 * The AudioSessionManager initializes the audio devices and selects a starting audio device according to the following priority order:
 * - Bluetooth
 * - Headset (or builtin earphone)
 * - Speaker
 */
@interface AudioSessionManager : NSObject

/**
 The current audio route.
 
 Valid values at this time are:
 - kAudioSessionManagerDevice_Bluetooth
 - kAudioSessionManagerDevice_Headset
 - kAudioSessionManagerDevice_Phone
 - kAudioSessionManagerDevice_Speaker
 
 Does nothing if you control audio route.
 */
@property (nonatomic, assign)     NSString        *audioRoute;

/**
 Returns YES if a wired headset is available. Do not use if you control audio route.
 */
@property (nonatomic, readonly)     BOOL             headsetDeviceAvailable;

/**
 Returns YES if a bluetooth device is available. Do not use if you control audio route.
 */
@property (nonatomic, readonly)     BOOL             bluetoothDeviceAvailable;

/**
 Returns YES if the device's earpiece is available (always true for now).
 */
@property (nonatomic, readonly)     BOOL             phoneDeviceAvailable;

/**
 Returns YES if the device's speakerphone is available (always true for now).
 */
@property (nonatomic, readonly)     BOOL             speakerDeviceAvailable;

/**
 Returns a list of the available audio devices. Valid values at this time are:
 - kAudioSessionManagerDevice_Bluetooth
 - kAudioSessionManagerDevice_Headset
 - kAudioSessionManagerDevice_Phone
 - kAudioSessionManagerDevice_Speaker
 Do not use if you control audio route.
 */
@property (nonatomic, readonly)     NSArray         *availableAudioDevices;

/**
 * @brief The application should set this to YES to tell the SDK that it wants to directly control audio routing using Apple audio management APIs
 * If not set, the Cloudonix Mobile SDK will handle audio routing and the application should use the 'audioRoute' property to select which route it wants to use.
 */
@property (nonatomic)   BOOL    controlAudioRoute;

/**
 Returns the AudioSessionManager singleton, creating it if it does not already exist.
 */
+ (instancetype)sharedInstance __attribute__((deprecated("This method will be removed in the future, use CloudonixSDKClient.audioSession instead")));

- (void)start __attribute__((deprecated("This method will be removed in the future. It was originally meant for internal use only.")));

- (void)inCall __attribute__((deprecated("This method will be removed in the future. It was originally meant for internal use only.")));
@end
