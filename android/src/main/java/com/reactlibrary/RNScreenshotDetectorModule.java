
package com.reactlibrary;

import android.app.Activity;
import android.view.Window;
import android.view.WindowManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNScreenshotDetectorModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNScreenshotDetectorModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNScreenshotDetector";
  }

  @ReactMethod
  public void disableScreenshots() {
    Activity currentActivity = getCurrentActivity();
    if (currentActivity != null) {
      currentActivity.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          Window window = getWindow();
          if (window != null) {
            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
          }
        }
      });
    }
  }

  @ReactMethod
  public void enableScreenshots() {
    Activity currentActivity = getCurrentActivity();
    if (currentActivity != null) {
      currentActivity.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          Window window = getWindow();
          if (window != null) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
          }
        }
      });
    }
  }

  private Window getWindow() {
    Activity currentActivity = getCurrentActivity();
    return currentActivity != null ? currentActivity.getWindow() : null;
  }
}
