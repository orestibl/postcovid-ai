package dk.cachet.activity_recognition_flutter;

import android.app.IntentService;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;

import io.flutter.plugin.common.EventChannel;

import java.util.Date;
import java.util.List;

import androidx.annotation.Nullable;
import java.util.Calendar;

public class ActivityRecognizedService extends IntentService {
    String TAG="ActivityRecognizedService";

    private EventChannel.EventSink eventSink;

    public ActivityRecognizedService() {
        super("ActivityRecognizedService");
        Log.d(TAG, "ActivityRecognizedService");

    }

    @Override
    public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        Log.d(TAG, "onHandleIntent");
        ActivityRecognitionResult result = ActivityRecognitionResult.extractResult(intent);
        List<DetectedActivity> activities = result.getProbableActivities();

        DetectedActivity mostLikely = activities.get(0);

        for (DetectedActivity a : activities) {
            if (a.getConfidence() > mostLikely.getConfidence()) {
                mostLikely = a;
            }
        }

        String type = getActivityString(mostLikely.getType());
        int confidence = mostLikely.getConfidence();

        String data = type + "," + confidence;

        Log.d("onHandleIntent", data);

        /// Same preferences as in ActivityRecognitionFlutterPlugin.java
        SharedPreferences preferences =
                getApplicationContext().getSharedPreferences(
                        ActivityRecognitionFlutterPlugin.ACTIVITY_RECOGNITION, MODE_PRIVATE);

        preferences.edit().clear()
                .putString(
                        ActivityRecognitionFlutterPlugin.DETECTED_ACTIVITY,
                        data
                )
                .apply();

        /// Same preferences as in ActivityRecognitionFlutterPlugin.java
        String currentTime = Calendar.getInstance().getTime().toString();
        String nuevo_valor = currentTime + ": " + ActivityRecognitionFlutterPlugin.DETECTED_ACTIVITY + ": " + data + ". ";
        SharedPreferences pref2 =
                getApplicationContext().getSharedPreferences("FlutterSharedPreferences", MODE_WORLD_READABLE);
        //hector, cambio MODE_PRIVATE por world...
        String valores_historicos = currentTime + pref2.getString("flutter.AR", null);
        // hector, quito .clear()
        pref2.edit().putString("flutter.AR", valores_historicos + nuevo_valor +"\n").apply();

    }

    public static String getActivityString(int type) {
        if (type == DetectedActivity.IN_VEHICLE) return "IN_VEHICLE";
        if (type == DetectedActivity.ON_BICYCLE) return "ON_BICYCLE";
        if (type == DetectedActivity.ON_FOOT) return "ON_FOOT";
        if (type == DetectedActivity.RUNNING) return "RUNNING";
        if (type == DetectedActivity.STILL) return "STILL";
        if (type == DetectedActivity.TILTING) return "TILTING";
        if (type == DetectedActivity.WALKING) return "WALKING";

        // Default case
        return "UNKNOWN";
    }
}