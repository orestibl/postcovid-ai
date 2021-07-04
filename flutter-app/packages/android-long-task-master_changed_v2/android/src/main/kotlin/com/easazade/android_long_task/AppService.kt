package com.easazade.android_long_task

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterMain
import org.json.JSONObject

class AppService : Service() {
  private val TAG: String = "HH_AppService"
  private val binder = LocalBinder()
  private val channel_name = "APP_SERVICE_CHANNEL_NAME"
  private val channel_name2 = "APP_SERVICE_CHANNEL_NAME2"
  private var channel: MethodChannel? = null
  //private var channel2: MethodChannel? = null
  var serviceData: JSONObject? = null
  private var observer: ((JSONObject) -> Unit)? = null
  private var executionResultListener: ((JSONObject) -> Unit)? = null
  private val notifId = 101
  private var engine: FlutterEngine? = null
  private var runDartCodeExecuted = false

  inner class LocalBinder : Binder() {
    fun getInstance(): AppService = this@AppService
  }

  fun setServiceDataObserver(observer: ((JSONObject) -> Unit)?) { //hector: le añado que pueda ser null para poder quitar el observer cuando se destruya la app principal
    Log.d(TAG, "setServiceDataObserver")
    this.observer = observer
  }

  fun setMethodExecutionResultListener(listener: (JSONObject) -> Unit) {
    Log.d(TAG, "setMethodExecutionResultListener")
    this.executionResultListener = listener
  }

  fun runDartFunction() {
    Log.d(TAG, "runDartFunction")
    //    channel = MethodChannel(messenger, channel_name)
    //    channel?.invokeMethod(dartFunctionName, "arguments from service")
    FlutterLoader.getInstance().startInitialization(this)
    FlutterLoader.getInstance().ensureInitializationComplete(this, emptyArray<String>())
    // hector: he cambiado FlutterMain por FlutterLoader por estar deprecated pero sigue dando deprecated "getInstance"
    //    FlutterMain.startInitialization(this)
    //    FlutterMain.ensureInitializationComplete(this, emptyArray<String>())

    engine = FlutterEngine(applicationContext)
    //engine!!.renderer.startRenderingToSurface(getHolder.getSurface()) // necesito una Surface para poder usar UI --> después de una primera búsqueda, no parece cosa fácil -> descartamos UI (aunque se puede ejecutar en serviceMain runApp (pero no sale nada por pantalla)

    val entrypoint = DartEntrypoint("lib/main.dart", "serviceMain")
    Log.d(TAG, "ANTES de executeDartEntrypoint (se usa el mismo hilo de AppService entiendo por lo que hay que esperar a que se ejecute para seguir")
    engine!!.dartExecutor.executeDartEntrypoint(entrypoint)

    Log.d(TAG, "DESPUÉS de executeDartEntrypoint y Thread.sleep. Ya se ha ejecutado de serviceMain (REALMENTE NO!!! es una hebra que se ejecuta cuando acabo runDartFunction(), pero el caso es que se recibe el invokeMethod aunque el canal del otro lado todavía no está listo, se ve que se queda en una cola) que esencialmente define algunos callbacks en la parte dart de APP_SERVICE_CHANNEL_NAME, entre ellos, runDartCode que se va a llamar después")
    channel = MethodChannel(engine!!.dartExecutor.binaryMessenger, channel_name)
    Log.d(TAG, "Creo $channel_name, channel = $channel y defino los MethodCallHandlers")
    //    channel2 = MethodChannel(engine!!.dartExecutor.binaryMessenger, channel_name2)
    //    Log.d(TAG, "Creo $channel_name2, channel = $channel2")


    channel!!.setMethodCallHandler { call, result ->
      Log.d(TAG, "${channel_name} received a method call: ${call.method} -> ${call.arguments?.toString()}")

      if (call.method == "STOP_SERVICE") {
        stopDartService()
        result.success("stopped service")
      } else if (call.method == "SET_SERVICE_DATA") {
        try { //porque sepa Dios si los call.arguments son correctos
          val jObject = JSONObject(call.arguments as String)
          Log.d(TAG, "update json data from service client -> $jObject")
          setData(jObject)
          result.success("set data on service")
        } catch (e: Throwable) {
          result.error("CODE: FAILED SETTING DATA", "!!! Failed to set data on service !!!", "")
          e.printStackTrace()
        }
      } else if (call.method == "END_EXECUTION") {
        try { //porque sepa Dios si los call.arguments son correctos
          val jObject = JSONObject(call.arguments as String)
          endExecution(jObject)
          result.success("!!! Ended execution.")
        } catch (e: Throwable) {
          result.error("CODE:FAILED ENDING EXECUTION", "!!! failed to end the execution", "")
          e.printStackTrace()
        }
      } else if (call.method == "SEND_ACK") {
          result.success("SEND_ACK RECEIVED. NOW I WILL CALL sendAckToLongTask")
          sendAckToLongTask()
      }
    }
  }
    // ESTO LO PONGO EN OTRA FUNCIÓN PARA QUE DÉ TIEMPO A QUE EL CANAL ESTÉ CREADO POR EL OTRO LADO
//    //Thread.sleep(25) // a ver si damos tiempo...
//    Log.d(TAG, "invoco runDartCode del canal $channel_name")
//    if (serviceData != null) {
//      channel!!.invokeMethod("runDartCode", serviceData.toString())
//    } else {
//      Log.e(TAG, "please set ServiceData before calling execute")
//    }

  fun invokeRunDartCode() { // lo pongo en otra función y en otra llamada para que dé tiempo a crear el canal en el otro lado
    //Thread.sleep(25) // a ver si damos tiempo...
    Log.d(TAG, "invoco runDartCode del canal $channel_name")
    if (serviceData != null) {
      channel!!.invokeMethod("runDartCode", serviceData.toString())
    } else {
      Log.e(TAG, "please set ServiceData before calling execute")
    }
    runDartCodeExecuted = true
  }
  fun stopDartService() {
    Log.d(TAG, "stopDartService")
    runDartCodeExecuted = false
    // notificamos a la dart function que queremos que acabe (si no lo ha hecho ya)
    channel!!.invokeMethod("endDartCode", "")
    // debería poner un delay para dar tiempo al dart code a hacer sus disposes???
    stopForeground(true)
    stopSelf()
    Log.d(TAG, "stopDartService service stopped")
    engine?.destroy() // no debería hacerese esto primero???
    Log.d(TAG, "stopDartService engine destroyed")
  }

  fun sendUiPresent() {
    Log.d(TAG, "sendUiPresent")
    // notificamos a la dart function que la UI está presente (¿y si todavía no está running?)
    if (runDartCodeExecuted) {
      channel!!.invokeMethod("uiPresent", "")
    }
  }
  fun sendUiNotPresent() {
    Log.d(TAG, "sendUiNotPresent. Además, ponemos executionResultListener =null")
    // notificamos a la dart function que la UI NO está presente
    if (runDartCodeExecuted) {
      executionResultListener = null // ya no tiene sentido devolver nada cuando acabe la función (ya no existe la app original)
      channel!!.invokeMethod("uiNotPresent", "")
    }
  }
  fun sendAckToLongTask() {
    Log.d(TAG, "sendAckToLongTask") // no sé si el callhandler de la long task sigue funcionando después de mucho tiempo...
    // notificamos a la dart function que la UI está presente (¿y si todavía no está running?)
    if (runDartCodeExecuted) {
      channel!!.invokeMethod("AckToLongTask", "")
    }
  }

  override fun onCreate() {
    Log.d(TAG, "onCreate. Se hace startForeground")
    super.onCreate()
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    val pm = applicationContext.packageManager
    val notificationIntent = pm.getLaunchIntentForPackage(applicationContext.packageName)
    val pendingIntent = PendingIntent.getActivity(this, 0,
            notificationIntent, 0)

    val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(getMipMapIconId())
            .setContentIntent(pendingIntent)
            .setContentTitle("Study not initialized")
            .setContentText("Tap to open")
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)

    startForeground(notifId, builder.build())
//    }

  }

  override fun onBind(intent: Intent?): IBinder? {
    Log.d(TAG, "onBind. Devolviendo un puntero a la única instancia de AppService")
    return binder
  }

  fun setData(data: JSONObject?) {
    Log.d(TAG, "setData")
    Log.d(TAG, data?.toString() ?: "json data is null")
    serviceData = data
    data?.let {
      Log.d(TAG, "Enviando serviceData a través del observer, que apunta a serviceDataObserver de AndroidLongTask y luego se hace updateNotification")
      observer?.invoke(it)
      if (it.has("notif_title") && it.has("notif_description")) {
        val title = it.getString("notif_title")
        val description = it.getString("notif_description")
        updateNotification(title, description)
      }
    }
  }

  private fun endExecution(data: JSONObject?) {
    Log.d(TAG, "endExecution. Como argumentos los valores que debemos poner en serviceData por si me los piden después")
    Log.d(TAG, data?.toString() ?: "result data is null")
    serviceData = data
    Log.d(TAG, "endExecution, actualizamos notification")
    data?.let {
      if (it.has("notif_title") && it.has("notif_description")) {
        val title = it.getString("notif_title")
        val description = it.getString("notif_description")
        updateNotification(title, description)
      }
      Log.d(TAG, "endExecution, ejecutamos executionResultListener?.invoke(it) para devolver result.success de cuadno se invocó RUN_DART_FUNCTION, que por fin acaba ahora... no sé si esto puede dar problemas porque la app puede que ni si quiera exista para entonces")
      executionResultListener?.invoke(it) // aquí es cuando devolvemos result.success de RUN_DART_FUNCTION (fíjate que el result.sucess de END_EXCUTION se envía justo cunado acabe esta función). Lo mismo ya no está ni la app en ejecución !!!
    }
  }

  private fun updateNotification(title: String, description: String) {
    //    Log.d(TAG, "channel2 = $channel2: REALMENTE ESTE CANAL ES INNECESARIO: QUITARLO CUANDO HAYAS HECHO LOS CALLBACKS en service_client.dart")
    //    if (channel2 != null) {
    //      channel2!!.invokeMethod("MENSAJE AL SERVIDOR", null)
    //    }
    Log.d(TAG, "updateNotification(title|description) => $title | $description")
    val pm = applicationContext.packageManager
    val notificationIntent = pm.getLaunchIntentForPackage(applicationContext.packageName)
    val pendingIntent = PendingIntent.getActivity(this, 0,
            notificationIntent, 0)


//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    val builder = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentText(description)
        .setContentTitle(title)
        .setSmallIcon(getMipMapIconId())
            .setContentIntent(pendingIntent)
//            .setOngoing(true)
//            .setCategory(NotificationCompat.CATEGORY_SERVICE)

    startForeground(notifId, builder.build())
//    }

  }

  private fun getMipMapIconId(): Int =
      this.applicationContext.resources.getIdentifier(
          "ic_launcher",
          "mipmap",
          this.applicationContext.packageName
      )

}