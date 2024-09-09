package com.exotel.voice_sample;

import com.exotel.voice.ExotelVoiceError;

public interface LogUploadEvents {

    void onUploadLogSuccess();

    void onUploadLogFailure(ExotelVoiceError error);

}
