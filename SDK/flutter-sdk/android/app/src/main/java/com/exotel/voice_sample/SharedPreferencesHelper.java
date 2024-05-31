package com.exotel.voice_sample;


import android.content.Context;
import android.content.SharedPreferences;

import static android.content.Context.MODE_PRIVATE;

public class SharedPreferencesHelper {

    private Context context;
    private static String TAG = "SharedPreferencesHelper";
    private static SharedPreferencesHelper mSharedPreferencesHelper;
    private SharedPreferencesHelper(Context context) {
        this.context = context;
    }

    public static SharedPreferencesHelper getInstance(Context context) {
        if(null == mSharedPreferencesHelper) {
            mSharedPreferencesHelper = new SharedPreferencesHelper(context);
        }
        return mSharedPreferencesHelper;
    }
    public String getString(String key) {

        String sharedPrefFile = context.getPackageName();
        SharedPreferences preferences = context.getSharedPreferences(sharedPrefFile, MODE_PRIVATE);
        return preferences.getString(key,"");
    }

    public boolean getBoolean(String key) {

        String sharedPrefFile = context.getPackageName();
        SharedPreferences preferences = context.getSharedPreferences(sharedPrefFile, MODE_PRIVATE);
        boolean bool = preferences.getBoolean(key,false);
        VoiceAppLogger.debug(TAG,"Key: "+key +" Value is: "+bool);
        return bool;
    }

    public void putString(String key, String value) {
        String sharedPrefFile = context.getPackageName();
        SharedPreferences preferences = context.getSharedPreferences(sharedPrefFile,MODE_PRIVATE);

        SharedPreferences.Editor preferencesEditor = preferences.edit();

        preferencesEditor.putString(key,value);
        preferencesEditor.apply();
    }

    public void putBoolean(String key, boolean value) {

        String sharedPrefFile = context.getPackageName();
        SharedPreferences preferences = context.getSharedPreferences(sharedPrefFile,MODE_PRIVATE);

        SharedPreferences.Editor preferencesEditor = preferences.edit();

        preferencesEditor.putBoolean(key,value);
        preferencesEditor.apply();
    }

}

