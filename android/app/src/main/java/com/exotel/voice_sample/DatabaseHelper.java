package com.exotel.voice_sample;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import java.util.ArrayList;
import java.util.Date;

/* Class that uses SQLLite DB to save the Recent Calls */
public class DatabaseHelper extends SQLiteOpenHelper {

    public static final String DATABASE_NAME = "Recent_Calls.db";
    public static final String TABLE_NAME = "call_table";
    public static final String COL_ID = "ID";
    public static final String COL_CALLER_ID = "CALLER_ID";
    public static final String COL_TIME = "TIME";
    private final Object dbSynchronization = new Object();
    public static final String COL_CALL_TYPE = "CALL_TYPE";

    private Integer MAX_NUM_ENTRIES = 20;

    private static String TAG = "DatabaseHelper";
    private static DatabaseHelper mDatabaseHelper;
    private DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, 1);
        VoiceAppLogger.debug(TAG,"DatabaseHelper constructor");

    }

    public static DatabaseHelper getInstance(Context context) {
        if(null == mDatabaseHelper) {
            mDatabaseHelper = new DatabaseHelper(context);
        }
        return mDatabaseHelper;
    }

    @Override
    public void onCreate(SQLiteDatabase sqLiteDatabase) {
        sqLiteDatabase.execSQL("create table " + TABLE_NAME +" (ID INTEGER PRIMARY KEY,CALLER_ID TEXT,TIME INTEGER,CALL_TYPE TEXT)");
        VoiceAppLogger.debug(TAG,"DatabaseHelper onCreate");
    }

    @Override
    public void onUpgrade(SQLiteDatabase sqLiteDatabase, int i, int i1) {
        sqLiteDatabase.execSQL("DROP TABLE IF EXISTS "+TABLE_NAME);
        onCreate(sqLiteDatabase);
        VoiceAppLogger.debug(TAG,"DatabaseHelper onUpgrade");
    }

    boolean insertData(String callerId, Date time, CallType callType) {

        checkAndDelete();

        VoiceAppLogger.debug(TAG,"Insert, callerId: "+callerId+ " callType: "+callType +" Time: "+time);

        synchronized (dbSynchronization) {
            SQLiteDatabase db = this.getWritableDatabase();
            ContentValues contentValues = new ContentValues();
            contentValues.put(COL_CALLER_ID,callerId);
            Log.d(TAG,"Saving Date value as: "+time.getTime());
            contentValues.put(COL_TIME,time.getTime());
            contentValues.put(COL_CALL_TYPE,callType.toString());
            long result = db.insert(TABLE_NAME,null ,contentValues);

            if(result == -1) {
                VoiceAppLogger.debug(TAG,"Returning false from insert");
                return false;
            }

            else {
                VoiceAppLogger.debug(TAG,"Returning true from insert");
                return true;
            }
        }


    }

    private void checkAndDelete() {

        Log.d(TAG,"In checkAndDelete function for SQLLite");

        SQLiteDatabase db = this.getReadableDatabase();
        long count = DatabaseUtils.queryNumEntries(db, TABLE_NAME);
        //db.close();
        Log.d(TAG,"Number of items in DB is: "+count);
        if(count > MAX_NUM_ENTRIES) {
            /* Get the latest entry */
            String query = "SELECT * FROM "+ TABLE_NAME + " ORDER BY TIME ASC Limit 1";
            Cursor cursor = db.rawQuery(query,null);
            while (cursor.moveToNext()){

                Integer userIdToDelete = cursor.getInt(cursor.getColumnIndex(COL_ID));
                Log.d(TAG,"In check and Delete, userId to delete is: "+userIdToDelete);
                deleteData(userIdToDelete.toString());

            }
        }

    }

    @SuppressLint("Range")
    ArrayList<RecentCallDetails> getAllData() {

        synchronized (dbSynchronization) {
            SQLiteDatabase db = this.getWritableDatabase();
            String query = "SELECT * FROM "+ TABLE_NAME + " ORDER BY TIME DESC";
            Cursor cursor = db.rawQuery(query,null);
            ArrayList<RecentCallDetails> callList = new ArrayList<>();
            while (cursor.moveToNext()){

                RecentCallDetails callDetails = new RecentCallDetails();
                callDetails.setCallType(CallType.valueOf(cursor.getString(cursor.getColumnIndex(COL_CALL_TYPE))));
                callDetails.setRemoteId(cursor.getString(cursor.getColumnIndex(COL_CALLER_ID)));
                //Long mili = cursor.get
                callDetails.setTime(new Date(cursor.getLong(cursor.getColumnIndex(COL_TIME))));

                Log.d(TAG,"Call Type: "+callDetails.getCallType() + " Time: "+callDetails.getTime() + " remote ID: "+callDetails.getRemoteId());
                callList.add(callDetails);


            }
            cursor.close();
            return callList;
        }


    }


    Integer deleteData (String id) {
        Log.d(TAG,"In delete function with ID: "+id);
        synchronized (dbSynchronization) {
            SQLiteDatabase db = this.getWritableDatabase();
            return db.delete(TABLE_NAME, "ID = ?",new String[] {id});
        }

    }
}
