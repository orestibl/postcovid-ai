package com.easazade.android_long_task

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import android.content.Context
import android.content.SharedPreferences

/** AndroidLongTaskPlugin */
class AndroidLongTaskPlugin : FlutterPlugin, ActivityAwareAdapter() {
  private val TAG: String = "HH_AndroidLongTaskPlug"
  private var activity: FlutterActivity? = null
  private var androidLongTask: AndroidLongTask? = null
  private var binaryMessenger: BinaryMessenger? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(TAG, "onAttachedToEngine. Ojo, esto se ejecuta, como mínimo, dos veces, una cuando la app comienza y otra cuando se crea el nuevo FlutterEngine para ejecutar serviceMain. En el segundo caso, no se ejecuta onAttachedToActivity")
    binaryMessenger = flutterPluginBinding.binaryMessenger
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (activity==null) {
      Log.d(TAG, "onDetachedFromEngine del plugin del nuevo FlutterEngine, el que se crea al hacer RUN_DART_FUNCTION y que realmente no hace nada ni crea bindings ni nada")
    }
    else {
      Log.d(TAG, "onDetachedFromEngine del plugin del FlutterEngine de la app")
      // val sharedPreferences = binding.applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
      // val valor = sharedPreferences.getLong("flutter.RUNNING", -1)
      // Log.d(TAG, "flutter.RUNNING = ${valor.toString()}" )
      // var editor = sharedPreferences.edit()
      // editor.putLong("flutter.RUNNING", 100)
      // editor.commit()
      //androidLongTask?.channel?.setMethodCallHandler(null)
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(TAG, "onAttachedToActivity. Solo cuando hay activity se hace el binding y se crea AndroidLongTask")
    activity = binding.activity as FlutterActivity
    androidLongTask = AndroidLongTask(activity!!, binaryMessenger!!)
  }


  override fun onDetachedFromActivity() {
    Log.d(TAG, "onDetachedFromActivity. Ejecutamos detachApp()")
    //super.onDetachedFromActivity() // no tiene mucho sentido, solo llamaría a esa función en ActivityAwareAdapter.kt que no hace nada
    androidLongTask?.detachApp()
  }
}
