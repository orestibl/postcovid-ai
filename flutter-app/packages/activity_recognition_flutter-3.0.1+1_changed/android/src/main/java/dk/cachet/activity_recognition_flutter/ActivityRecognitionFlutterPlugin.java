package dk.cachet.activity_recognition_flutter;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.preference.PreferenceManager;
import android.util.Log;

import com.google.android.gms.location.ActivityRecognition;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import java.util.HashMap;

import androidx.annotation.NonNull;

import androidx.annotation.RequiresApi;
import androidx.lifecycle.OnLifecycleEvent;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

/**
 * ActivityRecognitionFlutterPlugin
 */
public class ActivityRecognitionFlutterPlugin implements FlutterPlugin, EventChannel.StreamHandler, ActivityAware,
    SharedPreferences.OnSharedPreferenceChangeListener {

  private EventChannel channel;
  private EventChannel.EventSink eventSink;
  private Activity androidActivity;
  private Context androidContext;
  public static final String DETECTED_ACTIVITY = "detected_activity";
  public static final String ACTIVITY_RECOGNITION = "activity_recognition_flutter";

  private final String TAG = "ActivityRecognitionFlutterPlugin";

  /**
   * The main function for starting activity tracking. Handling events is done
   * inside [ActivityRecognizedService]
   */
  private void startActivityTracking() {
    Log.d(TAG, "startActivityTracking");

    // Start the service
    Intent intent = new Intent(androidActivity, ActivityRecognizedService.class);
    PendingIntent pendingIntent = PendingIntent.getService(androidActivity, 0, intent,
        PendingIntent.FLAG_UPDATE_CURRENT);

    /// Frequency in milliseconds
    long frequency = 60 * 1000;
    Task<Void> task = ActivityRecognition.getClient(androidContext).requestActivityUpdates(frequency, pendingIntent);

    task.addOnSuccessListener(new OnSuccessListener<Void>() {
      @Override
      public void onSuccess(Void e) {
        Log.d(TAG, "ActivityRecognition: onSuccess");
      }
    });
    task.addOnFailureListener(new OnFailureListener() {
      @Override
      public void onFailure(@NonNull Exception e) {

        Log.d(TAG, "ActivityRecognition: onFailure:" + e.toString());
      }
    });
  }

  /**
   * EventChannel.StreamHandler interface below
   */

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), ACTIVITY_RECOGNITION);
    channel.setStreamHandler(this);
    // HECTOR: LO AÑADO PARA QUE FUNCIONE DESDE UN SERVICIO
    androidContext = flutterPluginBinding.getApplicationContext();
    // ESTO ESTABA EN onAttachedToActivity pero lo pongo aquí porque si se llama desde un servicio, esa parte no se ejecuta
    // Eso sí, habrás tenido que llamar a onListen priero desde la app con activiy y luego cerrar ese stream
    SharedPreferences prefs = androidContext.getSharedPreferences(ACTIVITY_RECOGNITION, Context.MODE_PRIVATE);
    prefs.registerOnSharedPreferenceChangeListener(this);
    Log.d(TAG, "onAttachedToEngine");
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    Log.d(TAG, "onListen");
    HashMap<String, Object> args = (HashMap<String, Object>) arguments;
    Log.d(TAG, "args: " + args);
    boolean fg = (boolean) args.get("foreground");
    Log.d(TAG, "foreground: " + fg);
    // Log.d(TAG,
    // "HECTOR: DESACTIVO LA LLAMADA A startForegroundService en onListen de
    // ActivityRecognitionFlutterPlugin.java");
    if (fg) {
      startForegroundService();
      Log.d(TAG, "Calling startForegroundService");
    }
    else {
      Log.d(TAG, "NOT calling startForegroundService. Supongo que desde otro plugin lo haces. Tienes 1 minuto... ");
    }


    eventSink = events;
    if (androidActivity!= null) {
      startActivityTracking();
    }
    else {
      Log.d(TAG, "androidActivity == null -> no llamo a startActivityTracking ya que supongo que está ya corriendo de antes...");
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  void startForegroundService() {
    Log.d(TAG, "startForegroundService");
    Intent intent = new Intent(androidActivity, ForegroundService.class);

    // Tell the service we want to start it
    intent.setAction("start");

    // Pass the notification title/text/icon to the service
    intent.putExtra("title", "MonsensoMonitor").putExtra("text", "Monsenso Foreground Service")
        .putExtra("icon", R.drawable.common_full_open_on_phone).putExtra("importance", 3).putExtra("id", 10);

    // Start the service
    androidContext.startForegroundService(intent);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d(TAG, "onDetachedFromEngine");
    channel.setStreamHandler(null);
  }

  @Override
  public void onCancel(Object arguments) {
    Log.d(TAG, "onCancel");
    channel.setStreamHandler(null);
  }

  /**
   * ActivityAware interface below
   */
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    androidActivity = binding.getActivity();
    androidContext = binding.getActivity().getApplicationContext();

//    SharedPreferences prefs = androidContext.getSharedPreferences(ACTIVITY_RECOGNITION, Context.MODE_PRIVATE);
//    prefs.registerOnSharedPreferenceChangeListener(this);
    Log.d(TAG, "onAttachedToActivity");
  }


  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "onDetachedFromActivityForConfigChanges");
    androidActivity = null;
    androidContext = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.d(TAG, "onReattachedToActivityForConfigChanges");
    androidActivity = binding.getActivity();
    androidContext = binding.getActivity().getApplicationContext();
  }

  @Override
  public void onDetachedFromActivity() {
    Log.d(TAG, "onDetachedFromActivity");
    androidActivity = null;
    androidContext = null;
  }

  /**
   * Shared preferences changed, i.e. latest activity
   */
  @Override
  public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
    String result = sharedPreferences.getString(DETECTED_ACTIVITY, "error");
    Log.d("SharedPrefs Changed", result);
    if (key != null && key.equals(DETECTED_ACTIVITY)) {
      Log.d(TAG, "Detected activity: " + result);
      try {
        this.eventSink.success(result);
        Log.d(TAG, "Acabo de hacer this.eventSink.success(result)");

      //} catch (NullPointerException | NoSuchMethodError  e) {
      } catch (Exception e) {
        Log.d(TAG, "OJO ERROR ERROR al hacer this.eventSink.success(result)" + e.toString());
      }
    }
  }
}
