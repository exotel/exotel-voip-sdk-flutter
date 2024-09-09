package com.exotel.voice_sample;


import java.util.Date;

public class RecentCallDetails {


    private String remoteId;

    private CallType callType;

    private Date time;


    public RecentCallDetails() {

    }

    public RecentCallDetails(String remoteId, CallType callType, Date time) {
        this.remoteId = remoteId;
        this.callType = callType;
        this.time = time;
    }

    public String getRemoteId() {
        return remoteId;
    }

    public void setRemoteId(String remoteId) {
        this.remoteId = remoteId;
    }

    public CallType getCallType() {
        return callType;
    }

    public void setCallType(CallType callType) {
        this.callType = callType;
    }

    public Date getTime() {
        return time;
    }

    public void setTime(Date time) {
        this.time = time;
    }

}
