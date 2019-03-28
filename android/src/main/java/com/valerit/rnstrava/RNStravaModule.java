
package com.valerit.rnstrava;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.facebook.react.bridge.ReadableMap;
import com.garmin.fit.*;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;

public class RNStravaModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNStravaModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNReactNativeStrava";
    }

    @ReactMethod
    public void login(String client_id, String redirect_uri, String response_type, String approval_prompt, String scope) {
        response_type = response_type == null ? "code" : response_type;
        approval_prompt = approval_prompt == null ? "auto" : approval_prompt;
        scope = scope == null ? "activity:write,read" : scope;

        if (client_id == null) {
            Log.e("RNStrava:", "client_id missing!");
            return;
        }

        if (redirect_uri == null) {
            Log.e("RNStrava:", "redirect_uri missing!");
            return;
        }

        Uri intentUri = Uri.parse("https://www.strava.com/oauth/mobile/authorize")
                .buildUpon()
                .appendQueryParameter("client_id", client_id)
                .appendQueryParameter("redirect_uri", redirect_uri)
                .appendQueryParameter("response_type", response_type)
                .appendQueryParameter("approval_prompt", approval_prompt)
                .appendQueryParameter("scope", scope)
                .build();

        Intent intent = new Intent(Intent.ACTION_VIEW, intentUri);
        ReactContext context = getReactApplicationContext();
        context.startActivity(intent);
    }

    @ReactMethod
    public void generateFitFile(ReadableMap session, Promise promise) {
        // Required Parameters, unit
        FileEncoder encode;
        String fileName = UUID.randomUUID().toString();
        java.io.File file;
        try {
            // , reactContext.getExternalMediaDirs()[0]
            file = java.io.File.createTempFile(fileName, ".fit");
        } catch (IOException e) {
            promise.reject("io_exception", "Failed to create a temp file! Please check if you have enough internal storage left.");
            return;
        }

        encode = new FileEncoder(file, Fit.ProtocolVersion.V2_0);

        DateTime timestamp = new DateTime(new Date((long) session.getDouble("date")));

        DateTime starTime = new DateTime(timestamp);
        starTime.add(-session.getDouble("runningTime"));
        Log.d("react-native-strava", timestamp.getDate().toString());

        // TODO: use the right Manufacturer id, product id, serial number
        //Generate FileIdMessage
        FileIdMesg fileIdMesg = new FileIdMesg(); // Every FIT file MUST contain a 'File ID' message as the first message
        fileIdMesg.setManufacturer(Manufacturer.GARMIN);
        fileIdMesg.setType(File.ACTIVITY);
        fileIdMesg.setProduct(9001);
        fileIdMesg.setSerialNumber(1701L);
        fileIdMesg.setTimeCreated(timestamp);

        encode.write(fileIdMesg); // Encode the FileIDMesg

        EventMesg eventMesgStart = new EventMesg();
        eventMesgStart.setTimestamp(starTime);
        eventMesgStart.setEventType(EventType.START);
        encode.write(eventMesgStart);


        RecordMesg record = new RecordMesg();

        record.setActivityType(ActivityType.RUNNING);
        record.setTimestamp(starTime);

        record.setHeartRate((short) 0);
        record.setDistance(0.f);
        record.setSpeed(0.f);
        record.setCalories(0);

        // TODO: set steps
        encode.write(record);

        record.setActivityType(ActivityType.RUNNING);
        record.setTimestamp(timestamp);
        // TODO: extract lat, lng from session
//        record.setPositionLat(degreeToSemicircles(41.726667));
//        record.setPositionLong(degreeToSemicircles(44.883333));
        record.setHeartRate((short) session.getInt("pulse"));
        record.setDistance((float) session.getDouble("distance"));
        record.setSpeed((float) session.getDouble("speed"));
        record.setCalories(session.getInt("calories"));

        // TODO: set steps
        encode.write(record);

        EventMesg eventMesgEnd = new EventMesg();
        eventMesgEnd.setTimestamp(timestamp);
        eventMesgEnd.setEventType(EventType.STOP);
        encode.write(eventMesgEnd);

        LapMesg lapMsg = new LapMesg();
        lapMsg.setTimestamp(timestamp);
        lapMsg.setTotalElapsedTime((float) session.getDouble("runningTime"));
        lapMsg.setTotalTimerTime((float) session.getDouble("runningTime"));
        lapMsg.setTotalDistance((float) session.getDouble("distance"));

        EventMesg eventMesgDisableAll = new EventMesg();
        eventMesgDisableAll.setTimestamp(timestamp);
        eventMesgDisableAll.setEventType(EventType.STOP_DISABLE_ALL);
        encode.write(eventMesgDisableAll);

        SessionMesg sessionMsg = new SessionMesg();
        sessionMsg.setSport(Sport.RUNNING);
        sessionMsg.setStartTime(starTime);
        sessionMsg.setTotalElapsedTime((float) session.getDouble("runningTime"));
        sessionMsg.setTotalTimerTime((float) session.getDouble("runningTime"));
        sessionMsg.setTotalDistance((float) session.getDouble("distance"));
        sessionMsg.setTotalAscent(0);
        sessionMsg.setTimestamp(timestamp);
        encode.write(sessionMsg);

        ActivityMesg aMsg = new ActivityMesg();
        aMsg.setNumSessions(1);
        aMsg.setTotalTimerTime((float) session.getDouble("runningTime"));
        aMsg.setTimestamp(timestamp);

        encode.write(aMsg);

        try {
            encode.close();
        } catch (FitRuntimeException e) {
            promise.reject("io_exception", "Failed to finalize encoding.");
            return;
        }


        promise.resolve(file.getAbsolutePath());
    }

    @ReactMethod
    public void deleteFitFile(String path, Promise promise) {
    }

    int degreeToSemicircles(double d) {
        return (int) (d / 90.0 * 2147483647.0);
    }
}
