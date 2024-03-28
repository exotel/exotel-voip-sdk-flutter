package com.exotel.voice_sample;

import android.content.Context;
import android.util.Log;


import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import androidx.annotation.NonNull;

//import com.google.firebase.crashlytics.FirebaseCrashlytics;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class VoiceAppLogger {

    private static String TAG = "VoiceAppLogger";

    private static Context context;
    private static final  long DAY_IN_MS = 1000 * 60 * 60 * 24;
    private static final int ZIP_LOGS_AFTER_DAYS = 1;
    private static final int UPLOAD_LOG_NUM_DAYS = 7;

    static void debug(String tag, String message) {
        Log.d(tag,message);
        String text = "D/"+tag+":"+message;
        DateFormat timeformat = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        String time = timeformat.format(date);
        text = time + "-" + text;
//        FirebaseCrashlytics.getInstance().log(text);
        appendLog(text);
    }

    static void info(String tag, String message) {
        Log.i(tag, message);
        String text = "I/"+tag+":"+message;
        DateFormat timeformat = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        String time = timeformat.format(date);
        text = time + "-" + text;
//        FirebaseCrashlytics.getInstance().log(text);
        appendLog(text);
    }

    static void warn(String tag, String message) {
        Log.w(tag, message);
        String text = "W/"+tag+":"+message;
        DateFormat timeformat = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        String time = timeformat.format(date);
        text = time + "-" + text;
//        FirebaseCrashlytics.getInstance().log(text);
        appendLog(text);
    }

    static void error(String tag, String message) {
        Log.e(tag,message);
        String text = "E/"+tag+":"+message;
        DateFormat timeformat = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        String time = timeformat.format(date);
        text = time + "-" + text;
//        FirebaseCrashlytics.getInstance().log(text);
        if(!tag.equals("Cloudonix")) {
//            FirebaseCrashlytics.getInstance().recordException(new Exception(message));
        }
        appendLog(text);
    }

    static void setContext(Context ctx) {
        context = ctx;
    }

    /*static void appendLog(String text)
    {
        String fileName;
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        fileName = dateFormat.format(date);
        fileName = "sdcard/"+fileName + "-exotelVoip.txt";
        File logFile = new File(fileName);
        if (!logFile.exists())
        {
            try
            {
                logFile.createNewFile();
            }
            catch (IOException e)
            {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        try
        {
            //BufferedWriter for performance, true to set append to file flag
            BufferedWriter buf = new BufferedWriter(new FileWriter(logFile, true));
            buf.append(text);
            buf.newLine();
            buf.close();
        }
        catch (IOException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }*/

    static void appendLog(String text)
    {
        String fileName;
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        fileName = dateFormat.format(date);

        fileName = "exotelSampleApp-" + fileName + ".txt";

        if(null == context) {
            return;
        }
        File logFile = new File(context.getFilesDir(), fileName);
        if (!logFile.exists())
        {
            try
            {
                logFile.createNewFile();
            }
            catch (IOException e)
            {
                // TODO Auto-generated catch block
                e.printStackTrace();
                return;
            }
        }
        try
        {
            //BufferedWriter for performance, true to set append to file flag
            BufferedWriter buf = new BufferedWriter(new FileWriter(logFile, true));
            buf.append(text);
            buf.newLine();
            buf.close();
        }
        catch (IOException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    static void uploadAppLogsToServer(Date startDate, Date endDate, String signedUrl, String fileName) {
        FileFilter filter = new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                VoiceAppLogger.debug(TAG,"In accept pathname is: "+pathname.toString() +" can read: "+pathname.canRead());
                if(pathname.isFile() && pathname.canRead() && (pathname.toString().contains(".txt") || pathname.toString().contains(".zip")) && pathname.toString().contains("exotelSampleApp-")) {
                    if(validateStartAndEndDate(startDate,endDate,pathname)) {
                        VoiceAppLogger.debug(TAG,"Returning true: "+pathname.toString());
                        return true;
                    } else {
                        VoiceAppLogger.debug(TAG,"Returning false: "+pathname.toString());
                        return false;
                    }

                } else {
                    VoiceAppLogger.debug(TAG,"Returning false: "+pathname.toString());
                    return false;
                }
            }
        };

        File [] fileList = context.getFilesDir().listFiles(filter);

        VoiceAppLogger.error(TAG,"Size of fileList: "+fileList.length);
        if(fileList.length > 0) {
            createZipFile(fileList,context.getFilesDir().toString() + "/" + fileName);

            uploadLogFile(signedUrl,fileName);

            VoiceAppLogger.debug(TAG,"After zip function");
        }
    }

    static void getSignedUrlForLogUpload() {
        OkHttpClient client = new OkHttpClient();
        SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper.getInstance(context);
        String hostname = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.APP_HOSTNAME.toString());
        String accountSid = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.ACCOUNT_SID.toString());
        String username = sharedPreferencesHelper.getString(ApplicationSharedPreferenceData.USER_NAME.toString());
        String url = hostname + "/accounts/" + accountSid + "/subscribers/" + username + "/logdestination";
        VoiceAppLogger.debug(TAG,"Sending request to: "+url);
        Request request = new Request.Builder()
                .url(url)
                .build();


        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NonNull Call call, @NonNull IOException e) {
                VoiceAppLogger.error(TAG, "Failure to get signed URL: " + e.getMessage());
            }

            @Override
            public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                VoiceAppLogger.debug(TAG, "getSignedUrl: Got response code: " + response.code());
                String jsonData;

                if (null == response.body()) {
                    VoiceAppLogger.error(TAG, "getSignedUrl response is NULL");

                    return;
                }
                jsonData = response.body().string();
                JSONObject jObject;

                if (200 != response.code()) {
                    VoiceAppLogger.error(TAG, "Response code is: " + response.code());
                    return;
                }
                try {
                    jObject = new JSONObject(jsonData);
                    String uploadUrl;
                    String fileName;
                    uploadUrl = jObject.getString("logDestinationURL");
                    fileName = jObject.getString("logDestinationFileName");

                    if (uploadUrl.isEmpty() || !uploadUrl.contains("http")) {
                        VoiceAppLogger.debug(TAG, "upload URL is empty or does not start with http");
                        return;
                    }
                    if (fileName.isEmpty()) {
                        VoiceAppLogger.error(TAG, "File name to upload logs is empty");
                        return;
                    }
                    Date endDate = new Date();
                    Date startDate = new Date(endDate.getTime() - (UPLOAD_LOG_NUM_DAYS * DAY_IN_MS));
                    VoiceAppLogger.uploadAppLogsToServer(startDate, endDate, uploadUrl, fileName);
                } catch (JSONException e) {
                    VoiceAppLogger.error(TAG, "Exception in reading response: " + e.getMessage());
                    response.body().close();
                    return;
                }
                response.body().close();
            }
        });
    }

    private static void createZipFile(File[] files, String zipFileName) {
        int BUFFER = 2048;
        VoiceAppLogger.debug(TAG,"Zip File Path is: "+zipFileName);
        try {
            BufferedInputStream origin;
            FileOutputStream dest = new FileOutputStream(zipFileName);
            ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(
                    dest));
            byte data[] = new byte[BUFFER];

            for(int i = 0; i < files.length; i++) {
                VoiceAppLogger.debug(TAG, "Adding: " + files[i].toString());
                FileInputStream fi = new FileInputStream(files[i].toString());
                origin = new BufferedInputStream(fi, BUFFER);

                VoiceAppLogger.debug(TAG,"Param passed to ZipEntry constructor is: "+files[i].toString().substring(files[i].toString().lastIndexOf("/") + 1));
                ZipEntry entry = new ZipEntry(files[i].toString().substring(files[i].toString().lastIndexOf("/") + 1));
                out.putNextEntry(entry);
                int count;

                while ((count = origin.read(data, 0, BUFFER)) != -1) {
                    out.write(data, 0, count);
                }
                origin.close();
            }

            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void uploadLogFile(String signedUrl, String fileName) {

        OkHttpClient client = new OkHttpClient();
        File file = context.getFileStreamPath(fileName);
        RequestBody requestBody = new MultipartBody.Builder().setType(MultipartBody.FORM)
                .addFormDataPart("file", file.getName(),
                        RequestBody.create(MediaType.parse("application/zip"), file))
                .build();

        Request request = new Request.Builder()
                .url(signedUrl)
                .put(requestBody)
                .build();

        client.newCall(request).enqueue(new Callback() {

            @Override
            public void onFailure(final Call call, final IOException e) {
                VoiceAppLogger.error(TAG,"Failure in uploading Log: "+e.getMessage());
                file.delete();

            }

            @Override
            public void onResponse(@NonNull final Call call, @NonNull final Response response) throws IOException {
                VoiceAppLogger.debug(TAG,"Got response for uploading log file: "+response.code());
                file.delete();

                // Upload successful
            }
        });
    }

    static void zipOlderLogs() {
        VoiceAppLogger.debug(TAG,"Zipping older log files");
        FileFilter filter = new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                VoiceAppLogger.debug(TAG,"In accept pathname for zipping is: "+pathname.toString() +" can read: "+pathname.canRead());
                if(pathname.isFile() && pathname.canRead() && pathname.canWrite() && (pathname.toString().contains(".txt")) && pathname.toString().contains("exotelSampleApp-")) {
                    if(checkFileForZip(pathname)) {
                        VoiceAppLogger.debug(TAG,"Returning true: "+pathname.toString());
                        return true;
                    } else {
                        VoiceAppLogger.debug(TAG,"Returning false: "+pathname.toString());
                        return false;
                    }

                } else {
                    VoiceAppLogger.debug(TAG,"Returning false: "+pathname.toString());
                    return false;
                }
            }
        };

        File [] fileList = context.getFilesDir().listFiles(filter);
        VoiceAppLogger.debug(TAG,"Size of fileList to delete is: "+fileList.length);
        for(int i = 0; i < fileList.length; i++) {
            VoiceAppLogger.debug(TAG,"FileName is: "+fileList[i].getName());
            File [] tempFileArr = new File[1];
            tempFileArr[0] = fileList[i];
            String zipFileName = fileList[i].getName();
            zipFileName = zipFileName.substring(0,(zipFileName.length() -3));
            zipFileName = zipFileName + "zip";
            VoiceAppLogger.debug(TAG,"Text file name: "+fileList[i].getName() +" Zip file name: "+zipFileName);
            zipFileName = context.getFilesDir() + "/" + zipFileName;
            createZipFile(tempFileArr,zipFileName);
            VoiceAppLogger.debug(TAG,"Deleting the file: "+fileList[i]);
            fileList[i].delete();
        }
    }

    private static boolean checkFileForZip(File pathname) {
        String fileName = pathname.getName();
        String []fileNameSplit = fileName.split("-");
        VoiceAppLogger.debug(TAG,"checkFileForZip: Size of fileName array is: "+fileNameSplit.length);
        if(fileNameSplit.length != 4) {
            return false;
        }

        int fileNameYear;
        int fileNameMonth;
        int fileNameDay;
        try {
            fileNameYear= Integer.parseInt(fileNameSplit[1]);
            fileNameMonth = Integer.parseInt(fileNameSplit[2]);
            fileNameDay = Integer.parseInt(fileNameSplit[3].substring(0,2));

        }catch (Exception e) {
            VoiceAppLogger.debug(TAG,"Exception is parsing Date for fileName: "+e.getMessage());
            return false;
        }
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        Date curDateIgnoreTime = calendar.getTime();


        calendar.set(fileNameYear, (fileNameMonth - 1) ,fileNameDay);
        Date fileDateIgnoreTime = calendar.getTime();



        VoiceAppLogger.debug(TAG,"FilenameYear: "+fileNameYear + "FileNameMonth: "+fileNameMonth + " fileNameDay: "+fileNameDay);
        VoiceAppLogger.debug(TAG,"Current Date: "+curDateIgnoreTime + "File Date: "+fileDateIgnoreTime);

        VoiceAppLogger.debug(TAG,"checkFileForZip: CurDate Ignore time: "+curDateIgnoreTime.getTime() + " File Date Ignore time: "+fileDateIgnoreTime.getTime());
        if(curDateIgnoreTime.getTime() - fileDateIgnoreTime.getTime() >= ZIP_LOGS_AFTER_DAYS * DAY_IN_MS) {
            VoiceAppLogger.debug(TAG,"checkFileForZip: Returning true");
            return true;
        }

        return false;
    }


    private static boolean validateStartAndEndDate(Date startDate, Date endDate, File pathname) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startDate);
        int startYear = calendar.get(Calendar.YEAR);
        /* Index is from 0 */
        int startMonth = calendar.get(Calendar.MONTH) + 1;
        int startDay = calendar.get(Calendar.DATE);

        calendar.setTime(endDate);
        int endYear = calendar.get(Calendar.YEAR);
        int endMonth = calendar.get(Calendar.MONTH) + 1;
        int endDay = calendar.get(Calendar.DATE);

        String fileName = pathname.getName();
        String []fileNameSplit = fileName.split("-");
        VoiceAppLogger.debug(TAG,"Size of fileName array is: "+fileNameSplit.length);
        if(fileNameSplit.length != 4) {
            return false;
        }

        int fileNameYear;
        int fileNameMonth;
        int fileNameDay;
        try {
            fileNameYear= Integer.parseInt(fileNameSplit[1]);
            fileNameMonth = Integer.parseInt(fileNameSplit[2]);
            fileNameDay = Integer.parseInt(fileNameSplit[3].substring(0,2));

        }catch (Exception e) {
            VoiceAppLogger.debug(TAG,"Exception is parsing Date for fileName: "+e.getMessage());
            return false;
        }
        calendar.set(fileNameYear, (fileNameMonth - 1) ,fileNameDay);
        Date fileDateIgnoreTime = calendar.getTime();
        Date startDateIgnoreTime;
        Date endDateIgnoreTime;

        calendar.set(startYear,(startMonth -1), startDay);
        startDateIgnoreTime = calendar.getTime();

        calendar.set(endYear,(endMonth -1), endDay);
        endDateIgnoreTime = calendar.getTime();

        if(fileDateIgnoreTime.compareTo(startDateIgnoreTime) >= 0 && fileDateIgnoreTime.compareTo(endDateIgnoreTime) <=0) {
            return true;
        }
        return false;
    }

}
