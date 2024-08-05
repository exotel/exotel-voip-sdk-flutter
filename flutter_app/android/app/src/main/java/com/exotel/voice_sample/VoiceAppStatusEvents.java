package com.exotel.voice_sample;

import com.exotel.voice.ExotelVoiceError;

public interface VoiceAppStatusEvents {
    void onInitializationSuccess();
    void onDeInitialization();
    void onInitializationFailure(ExotelVoiceError var1);

    void onAuthFailure();
    void onDestroyMediaSession();

}
