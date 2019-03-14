
package com.valerit.rnstrava;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

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
        approval_prompt = approval_prompt == null ? "auto" : response_type;
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
}