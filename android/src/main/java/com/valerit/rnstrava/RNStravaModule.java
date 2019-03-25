
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
            file = java.io.File.createTempFile(fileName,".fit");
        } catch (IOException e) {
            promise.reject("io_exception", "Failed to create a temp file! Please check if you have enough internal storage left.");
            return;
        }

        encode = new FileEncoder(file, Fit.ProtocolVersion.V2_0);

        // TODO: use the right Manufacturer id, product id, serial number
        //Generate FileIdMessage
        FileIdMesg fileIdMesg = new FileIdMesg(); // Every FIT file MUST contain a 'File ID' message as the first message
        fileIdMesg.setManufacturer(Manufacturer.DYNASTREAM);
        fileIdMesg.setType(File.ACTIVITY);
        fileIdMesg.setProduct(9001);
        fileIdMesg.setSerialNumber(1701L);

        encode.write(fileIdMesg); // Encode the FileIDMesg

        // TODO: use the correct app id
        byte[] appId = new byte[]{
                0x1, 0x1, 0x2, 0x3,
                0x5, 0x8, 0xD, 0x15,
                0x22, 0x37, 0x59, (byte) 0x90,
                (byte) 0xE9, 0x79, 0x62, (byte) 0xDB
        };

        DeveloperDataIdMesg developerIdMesg = new DeveloperDataIdMesg();
        for (int i = 0; i < appId.length; i++) {
            developerIdMesg.setApplicationId(i, appId[i]);
        }
        developerIdMesg.setDeveloperDataIndex((short)0);
        encode.write(developerIdMesg);

        FieldDescriptionMesg fieldDescMesg = new FieldDescriptionMesg();
        fieldDescMesg.setDeveloperDataIndex((short)0);
        fieldDescMesg.setFieldDefinitionNumber((short)0);
        fieldDescMesg.setFitBaseTypeId((short) Fit.BASE_TYPE_SINT8);
        fieldDescMesg.setFieldName(0, "doughnuts_earned");
        fieldDescMesg.setUnits(0, "doughnuts");
        encode.write(fieldDescMesg);

        RecordMesg record = new RecordMesg();
        DeveloperField devField = new DeveloperField(fieldDescMesg, developerIdMesg);
        record.addDeveloperField(devField);

        // Developer field
        DeveloperField doughnutsEarnedField = new DeveloperField(fieldDescMesg, developerIdMesg);
        record.addDeveloperField(doughnutsEarnedField);

        record.setActivityType(ActivityType.RUNNING);
        record.setHeartRate((short)session.getInt("pulse"));
        devField.setValue((short)session.getInt("pulse"));
        record.setDistance((float)session.getDouble("distance"));
        record.setSpeed((float)session.getDouble("speed"));
        record.setCalories(session.getInt("calories"));
        record.setTime128((float)session.getDouble("runningTime"));
        // TODO: set steps
        encode.write(record);

        try {
            encode.close();
        } catch (FitRuntimeException e) {
            promise.reject("io_exception", "Failed to finalize encoding.");
            return;
        }

        promise.resolve(file.getAbsolutePath());
    }
}
