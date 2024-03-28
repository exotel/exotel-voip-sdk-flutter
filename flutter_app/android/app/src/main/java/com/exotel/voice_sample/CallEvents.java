package com.exotel.voice_sample;

import com.exotel.voice.Call;

import java.util.Date;

public interface CallEvents {


    void onCallInitiated(Call call);

    void onCallRinging(Call call);

    void onCallEstablished(Call call);

    void onCallEnded(Call call);

    void onMissedCall(String remoteUserId, Date time);

    void onMediaDisrupted(Call call);

    void onRenewingMedia(Call call);
}
