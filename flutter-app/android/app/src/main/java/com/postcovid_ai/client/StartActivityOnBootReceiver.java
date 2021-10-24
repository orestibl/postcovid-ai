package com.postcovid_ai.client;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import io.flutter.Log;

public class StartActivityOnBootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Intent i = new Intent(context, MainActivity.class);
            // HECTOR, SE LO AÑADO COPIADO DE https://stackoverflow.com/questions/64642362/android-10-0-application-startup-on-boot y https://stackoverflow.com/questions/60699244/boot-completed-not-working-on-android-10-q-api-level-29/63250729#63250729
            //Log.d("StartActivityOnBootReceiver", "HH_HH_llego aquí?"); // this is printed
            // i.setAction(Intent.ACTION_MAIN);
            // i.addCategory(Intent.CATEGORY_LAUNCHER);
            //i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(i);
        }


    }


}

