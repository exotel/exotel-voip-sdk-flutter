package com.exotel.voice_sample;


import android.content.Context;
import android.media.AudioAttributes;
import android.media.SoundPool;
import android.os.Vibrator;
import android.os.VibrationEffect;
import android.media.AudioManager;
import android.os.Build;

public class RingTonePlayback {

    private SoundPool mSoundPool;
    private SoundPool mSoundPoolVoice;

    private boolean soundPoolLoaded;
    private boolean soundPoolVoiceLoaded;

    private int mRingingId;
    private int mBusyTone;
    private int mReorderTone;
    private int mWaitingTone;
    private int mStreamID;

    private static String TAG = "RingTonePlayback";
    Vibrator vibrator;
    private boolean vibrationStarted = false;
    private Context context;
    private final Object soundpoolSychronization = new Object();

    public RingTonePlayback(Context context) {
        this.context = context;
    }
    public void initializeTonePlayback() {
        mSoundPool = new SoundPool.Builder().setMaxStreams(1).setAudioAttributes(
                new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE).
                        build()).build();

        mSoundPoolVoice = new SoundPool.Builder().setMaxStreams(1).setAudioAttributes(
                new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION).
                        build()).build();

        mRingingId = mSoundPool.load(context, R.raw.exotel_ringtone, 1);
        mBusyTone = mSoundPoolVoice.load(context, R.raw.busy_tone, 1);
        mReorderTone = mSoundPoolVoice.load(context, R.raw.reorder_tone, 1);
        mWaitingTone = mSoundPoolVoice.load(context, R.raw.callwaiting_tone, 1);

        mSoundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId,
                                       int status) {
                synchronized (soundpoolSychronization) {

                    VoiceAppLogger.debug(TAG, "Sound pool is loaded");
                    soundPoolLoaded = true;
                    soundpoolSychronization.notifyAll();
                }

            }
        });

        mSoundPoolVoice.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId,
                                       int status) {
                synchronized (soundpoolSychronization) {

                    VoiceAppLogger.debug(TAG, "Sound pool voice is loaded");
                    soundPoolVoiceLoaded = true;
                    soundpoolSychronization.notifyAll();
                }

            }
        });
    }

    public void resetTonePlayback() {

        mSoundPool.release();
        mSoundPoolVoice.release();
    }

    public void startTone() {

        if(isVibrationModeOn()) {
            startVibration();
            return;
        }

        if (mStreamID > 0) {
            VoiceAppLogger.warn(TAG, "Tone already playing");
        } else {
            synchronized (soundpoolSychronization) {
                if (soundPoolLoaded) {
                    VoiceAppLogger.debug(TAG, "SoundPool play1");

                    mStreamID = mSoundPool.play(mRingingId, 1.0f, 1.0f, 1, -1, 1.0f);
                } else {
                    try {
                        soundpoolSychronization.wait(500);
                    } catch (Exception e) {
                        VoiceAppLogger.debug(TAG, "Wait for soundpool completetion exited: " + e.getMessage());
                        return;
                    }
                    VoiceAppLogger.debug(TAG, "SoundPool play 2");

                    mStreamID = mSoundPool.play(mRingingId, 1.0f, 1.0f, 1, -1, 1.0f);

                }
            }


        }
    }

    public void stopTone() {

        if(vibrationStarted) {
            stopVibration();
        }

        if (null != mSoundPool && 0 != mStreamID) {
            mSoundPool.stop(mStreamID);
            mStreamID = 0;
        }
    }

    private boolean isVibrationModeOn(){
        AudioManager am = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
        int ringMode = am.getRingerMode();

        VoiceAppLogger.debug(TAG, "Current ring mode : " + ringMode);
        if (ringMode == AudioManager.RINGER_MODE_VIBRATE)
            return  true;

        return false;
    }

    private void startVibration(){
        VoiceAppLogger.debug(TAG, "Vibrating phone now...");

        long[] mVibratePattern = new long[]{0, 1000, 1000, 1000};

        vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(mVibratePattern, 1));
        }
        else {
            vibrator.vibrate(mVibratePattern, 1);
        }

        vibrationStarted = true;
    }

    private void stopVibration() {
        VoiceAppLogger.debug(TAG, "Stopping vibration.");
        vibrator.cancel();
        vibrationStarted = false;
    }


    void playBusyTone() {
        synchronized (soundpoolSychronization) {
            if (soundPoolVoiceLoaded) {
                VoiceAppLogger.debug(TAG, "Playing busy tone");

                mSoundPoolVoice.play(mBusyTone, 1.0f, 1.0f, 1, 1, 1.0f);
            } else {

                VoiceAppLogger.error(TAG, "SoundPoolVoice not yet loaded");

            }
        }
    }

    void playReorderTone() {
        synchronized (soundpoolSychronization) {
            if (soundPoolVoiceLoaded) {
                VoiceAppLogger.debug(TAG, "Playing busy tone");

                mSoundPoolVoice.play(mReorderTone, 1.0f, 1.0f, 1, 1, 1.0f);
            } else {

                VoiceAppLogger.error(TAG, "SoundPoolVoice not yet loaded");

            }
        }
    }

    void playWaitingTone() {
        synchronized (soundpoolSychronization) {
            if (soundPoolVoiceLoaded) {
                VoiceAppLogger.debug(TAG, "Playing waiting tone");

                mSoundPoolVoice.play(mWaitingTone, 1.0f, 1.0f, 1, 0, 1.0f);
            } else {

                VoiceAppLogger.error(TAG, "SoundPoolVoice not yet loaded");

            }
        }
    }

}
