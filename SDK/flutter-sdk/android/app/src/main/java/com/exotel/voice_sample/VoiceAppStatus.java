package com.exotel.voice_sample;


public class VoiceAppStatus {


    private VoiceAppState state;

    private String message;

    public VoiceAppState getState() {
        return state;
    }

    public void setState(VoiceAppState state) {
        this.state = state;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
