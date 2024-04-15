package com.postcovid_ai.client;

import android.content.Intent;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @java.lang.Override
    protected void onCreate(android.os.Bundle savedInstanceState) {
        // Log.d("MainActivity.java", "HH_HH_llego aquí?");
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT > 28) {
            // HECTOR: VER https://stackoverflow.com/questions/64642362/android-10-0-application-startup-on-boot
            if (!Settings.canDrawOverlays(getApplicationContext())) {
                startActivity(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION));
            }
        }
    }
}

