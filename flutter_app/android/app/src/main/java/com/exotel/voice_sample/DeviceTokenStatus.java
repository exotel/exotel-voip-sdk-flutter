package com.exotel.voice_sample;

public class DeviceTokenStatus {


    private DeviceTokenState deviceTokenState;

    private String deviceTokenStatusMessage;

    public DeviceTokenState getDeviceTokenState() {
        return deviceTokenState;
    }

    public void setDeviceTokenState(DeviceTokenState deviceTokenState) {
        this.deviceTokenState = deviceTokenState;
    }

    public String getDeviceTokenStatusMessage() {
        return deviceTokenStatusMessage;
    }

    public void setDeviceTokenStatusMessage(String deviceTokenStatusMessage) {
        this.deviceTokenStatusMessage = deviceTokenStatusMessage;
    }
}
