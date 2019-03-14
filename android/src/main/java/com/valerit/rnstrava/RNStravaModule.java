
package com.valerit.rnstrava;

import com.facebook.react.bridge.ReactApplicationContext;
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

  }
}