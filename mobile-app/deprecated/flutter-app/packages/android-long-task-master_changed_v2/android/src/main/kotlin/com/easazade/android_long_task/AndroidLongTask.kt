package com.easazade.android_long_task

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.UiThread
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

const val CHANNEL_ID = "service_notification"


class AndroidLongTask(private val activity: FlutterActivity, private val binaryMessenger: BinaryMessenger) {
  private val TAG: String = "HH_AndroidLongTask"
  private val CHANNEL_NAME = "FSE_APP_CHANNEL_NAME" // Para comunicarme con app_client.dart
  private val START_SERVICE = "START_SERVICE"
  private val STOP_SERVICE = "STOP_SERVICE"
  private val RUN_DART_FUNCTION = "RUN_DART_FUNCTION"
  private val INVOKE_RUN_DART_CODE = "INVOKE_RUN_DART_CODE"
  private val SET_INITIAL_SERVICE_DATA = "SET_INITIAL_SERVICE_DATA"
  private val IS_SERVICE_RUNNING = "IS_SERVICE_RUNNING"
  private val GET_SERVICE_DATA = "GET_SERVICE_DATA"
  private val NOTIFY_UPDATE = "NOTIFY_UPDATE"
  private val APP_PAUSED = "APP_PAUSED"
  private val APP_RESUMED = "APP_RESUMED"
  private val APP_DETACHED = "APP_DETACHED"
  lateinit var channel: MethodChannel
  private lateinit var serviceIntent: Intent
  var appService: AppService? = null
  var initialServiceData: JSONObject? = null
  var serviceConnection: ServiceConnection? = null
  var onServiceStarted: (() -> Unit)? = null
  var appPaused: Boolean = true
  var appDetachedAlreadyReceived: Boolean = false

  init {
    Log.d(TAG, "init")
//    activity.lifecycle.addObserver(object : DefaultLifecycleObserver {
//      override fun onDestroy(owner: LifecycleOwner) {
//        Log.d(TAG, "onDestroy de la activity asociada. Pero aquí no hace falta que haga nada (creo)")
//      }
//    })
    createNotificationChannel()
    configure()
  }

  private fun createNotificationChannel() {
    Log.d(TAG, "createNotificationChannel")
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(CHANNEL_ID, "Messages", NotificationManager.IMPORTANCE_LOW)
      val manager = activity.getSystemService(NotificationManager::class.java)
      manager.createNotificationChannel(channel)
    }
  }

  @UiThread // HECTOR, ESTO LO AÑADO POR LO QUE SE DICE EN https://flutter.dev/docs/development/platform-integration/platform-channels?tab=android-channel-kotlin-tab
  private fun configure() {
    Log.d(TAG, "configure")
    serviceIntent = Intent(activity, AppService::class.java)
    val isRunning = isServiceRunning(AppService::class.java)
    Log.d(TAG, "################ isServiceRunning -> $isRunning")
    if (isRunning) {
      // ESTO LO HAGO PORQUE A VECES EN LA RE-ENTRADA DA PROBLEMAS Y MUCHAS VECES ES INNECESARIO HACER ESTO EN LA RE-ENTRADA PORQUE SOLO QUIERO SACAR UNA SURVEY Y TERMINAR -> SI QUIERO RECUPERAR EL BINDING CON EL SERVICIO, EJECUTO START_SERVICE explícitamete
      Log.d(TAG, "Ojo, aunque esté el servicio ya running no ejecuto startAndBindService-> debes llamar a START_SERVICE")
      //startAndBindService()
    }
    channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    Log.d(TAG, "Creado el MethodChannel FSE_APP_CHANNEL_NAME, ahora setMethodCallHandler")
    channel.setMethodCallHandler { call, result ->
      Log.d(TAG, "${CHANNEL_NAME} received a method call: ${call.method} -> ${call.arguments?.toString()}. appDetachedAlreadyReceived=$appDetachedAlreadyReceived")
      if (appDetachedAlreadyReceived) {
        Log.d(TAG,"ERROR!!!! ESTO NO PUEDE ESTAR PASANDO. LLAMAS A $CHANNEL_NAME ${call.method} CUANDO appDetachedAlreadyReceived = true")
        return@setMethodCallHandler
      }
      when (call.method) {
        SET_INITIAL_SERVICE_DATA -> {
          Log.d(TAG, "setting initial service data")
          setInitialServiceData(call.arguments as String)
          result.success("set data successfully")
        }
        IS_SERVICE_RUNNING -> {
          Log.d(TAG, "IS_SERVICE_RUNNING")
          if (isServiceRunning(AppService::class.java)) {
            Log.d(TAG, "service was already running, returning YES")
            result.success("YES")
          }
          else {
            Log.d(TAG, "service wasn't running, returning NO")
            result.success("NO")
          }
        }

        GET_SERVICE_DATA -> {
          Log.d(TAG, "getting service data")
          if (isServiceRunning(AppService::class.java)) {
            Log.d(TAG, "service was already running")
            result.success(appService?.serviceData?.toString())
          }
          else {
            Log.d("DART/NATIVE", "service wasn't running, returning initialServiceData")
            Log.d("DART/NATIVE", "service wasn't running, returning running: false")
            //result.success(initialServiceData.toString())
            result.success("{\"running\": \"no\"}")
          }
        }
        START_SERVICE -> {
          Log.d(TAG, "starting service")
          startAndBindService()
          onServiceStarted = { // guardamos lo que hay que devolver si all Ok. Pero hasta que no lo sepamos no lo hacemos
            result.success("service started successfully")
          }
        }
        STOP_SERVICE -> {
          Log.d(TAG, "stopping service")
          appService?.stopDartService()
          if (appService != null)
            serviceConnection?.let { activity.unbindService(it) }
          serviceConnection = null
          appService = null
          result.success("service stopped")
        }
        APP_DETACHED -> {
          Log.d(TAG, "APP_DETACHED: Eso quiere decir que AndroidLongTask.kt puede desaparecer en cualquier momento y se repondrá por uno nuevo cuando la app vuelva a ejecutarse desde el principio")
          detachApp()
          result.success("APP_DETACHED ACK")
        }
        APP_PAUSED -> {
          Log.d(TAG, "APP_PAUSED")
          appPaused = true
          result.success("APP_PAUSED ACK")
        }
        APP_RESUMED -> {
          Log.d(TAG, "APP_RESUMED")
          appPaused = false
          result.success("APP_RESUMED ACK")
          appService?.sendUiPresent() // se lo digo también a la long task 
        }
        RUN_DART_FUNCTION -> {
          Log.d(TAG, "RUN_DART_FUNCTION. call.arguments = ${call.arguments?.toString()}")
          if (appService != null) {
            Log.d(TAG, "RUN_DART_FUNCTION: ejecutamos appService!!.runDartFunction()")
            appService!!.runDartFunction()
            result.success("RUN_DART_FUNCTION success")
          } else {
            result.error("SERVICE_NOT_STARTED", "can't execute dart code before starting service", "")
          }
        }
        INVOKE_RUN_DART_CODE -> {
          Log.d(TAG, "INVOKE_RUN_DART_CODE. call.arguments = ${call.arguments?.toString()}")
          if (appService != null) {
            Log.d(TAG, "RUN_DART_FUNCTION: ejecutamos appService!!.invokeRunDartCode()")
            appService!!.invokeRunDartCode()
            Log.d(TAG, "RUN_DART_FUNCTION: ejecutamos appService!!.setMethodExecutionResultListener {jObject -> result.success(jObject.toString())}")
            appService!!.setMethodExecutionResultListener { jObject ->
              result.success(jObject.toString()) // lo guardamos ahí porque no podemos devolver nada hasta que se haya ejecutado... sepa Dios cuándo será eso!
            }
          } else {
            result.error("SERVICE_NOT_STARTED", "can't execute dart code before starting service", "")
          }
        }
      }
    }
    Log.d(TAG, "Acabado setMethodCallHandler")

  }

  fun detachApp() {
    Log.d(TAG, "detachApp: Ejecuto: channel.setMethodCallHandler(null); appService?.setServiceDataObserver(null); appService = null")
    //si es la primera vez que lo recibimos, hacemos esto. Pero es posible que se envíe tanto de la app en dart como desde onActiviyDetached --> no lo hacemos dos veces
    if (appDetachedAlreadyReceived) return
    appDetachedAlreadyReceived = true
    appPaused = true //AUNQUE YA DEBERÍA ESTAR A TRUE
    Log.d(TAG, "detachApp. OJO, no ejecuto channel.setMethodCallHandler(null) para ver si por cualquier razón se llama ")
    //channel.setMethodCallHandler(null)
    appService?.sendUiNotPresent() // se lo digo también a la long task
    if (appService!=null) { //si ha pasado por "STOP_SERVICE, all esto ya se ha hecho y daría un error si vuelvo a ejecutar activity?.unbindService(it)
      appService?.setServiceDataObserver(null)
      serviceConnection?.let { activity?.unbindService(it) }
    }
    appService = null
    Log.d(TAG, "Y para que no me dé un mensaje del tipo Activity com.easazade.android_long_task_example.MainActivity has leaked ServiceConnection com.easazade.android_long_task, llamo a unbindService")

  }

  private fun setInitialServiceData(jsonString: String) {
    Log.d(TAG, "setInitialServiceData")
    // try debido a que jsonString puede estar mal formada
    try { 
      val jObject = JSONObject(jsonString)
      Log.d(TAG, "json data is -> $jsonString")
      initialServiceData = jObject
    } catch (e: Throwable) {
      e.printStackTrace()
    }
  }

  private fun startAndBindService() {
    Log.d(TAG, "startAndBindService")
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      activity.startForegroundService(serviceIntent)
    } else {
      activity.startService(serviceIntent)
    }
    Log.d(TAG, "binding service")
    serviceConnection = createServiceConnection()
    activity.bindService(serviceIntent, serviceConnection!!, Context.BIND_AUTO_CREATE)
    Log.d(TAG, "ended binding service")
  }

  fun serviceDataObserver(jsonObject: JSONObject): Unit {
      Log.d(TAG, "HH_serviceDataObserver: invocando NOTIFY_UPDATE. Esta función se llama desde AppService pero pertence a AndroidLongTask. Check que funciona con app cerrada: sí que funciona!!!")
      // ADEMÁS, ES POSIBLE QUE EN EL OTRO LADO YA NO HAYA APP --> HAY QUE COMPROBARLO!!!!
      // ESTE MÉTODO SOLO SE PUEDE INVOCAR CUANDO SEPAMOS QUE HAY ALGUIEN AL OTRO LADO!!! ELSE DA UN WARNING: W/FlutterJNI: Tried to send a platform message to Flutter, but FlutterJNI was detached from native C++. Could not send. Channel: FSE_APP_CHANNEL_NAME. Response ID: 0
      if (!appPaused) {
        try {
          channel.invokeMethod(NOTIFY_UPDATE, jsonObject.toString())
        } catch (e: java.lang.Exception) {
          Log.d(TAG, "OJOOJOJOJO HH_serviceDataObserver: Hubo un error... pero lo ignoro!!!" + e)

        }

      }
      else Log.d(TAG, "No invoco NOTIFY_UPDATE ya que la app está pausada o inactiva")
    }
  private fun createServiceConnection(): ServiceConnection {
    Log.d(TAG, "createServiceConnection")
    return object : ServiceConnection {
      override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        Log.d(TAG, "onServiceConnected, ahora es cuando realmente obtengo el binding appService. Después llamo appService?setData(initialServiceData)")
        appService = (service as AppService.LocalBinder).getInstance()
        if (initialServiceData != null)
          appService?.setData(initialServiceData)
        Log.d(TAG, "onServiceConnected, Ahora es cuando devolvemos result.success de START_SERVICE")
        if (onServiceStarted != null) {
          Log.d(TAG, "y onServiceStarted no es null!!! está bien. Ten en cuenta que se hace binding también cuando se re-entra pero no es consecuencia de un START_SERVICE")
          onServiceStarted?.invoke()
        }

//        appService?.setServiceDataObserver { jsonObject ->
//          channel.invokeMethod(NOTIFY_UPDATE, jsonObject.toString())
//        }
        Log.d(TAG, "Ahora es cuando instalo el observer: appService?.setServiceDataObserver(::serviceDataObserver)")
        appService?.setServiceDataObserver(::serviceDataObserver) // HECTOR, LO PONGO ASÍ PORQUE ES MÁS FÁCIL DE ENTENDER (Y PUEDO PONER Log.d...)
      }

      override fun onServiceDisconnected(name: ComponentName?) {
        // onServiceDisconnected is only called in extreme situations (crashed / killed).
        Log.d(TAG, "onServiceDisconnected. Quito el obsever y finalmente el bind con AppService")
        appService?.setServiceDataObserver(null) // hector: se lo añado para que no se envíen serviceDataObserver las actualizaciones (no sirve para mucho porque esto no se ejecuta nunca realmente)
        appService = null
      }
    }
  }

  private fun isServiceRunning(serviceClass: Class<*>): Boolean {
    Log.d(TAG, "isServiceRunning")
    val manager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    for (service in manager.getRunningServices(Int.MAX_VALUE)) {
      if (serviceClass.name == service.service.className) {
        return true
      }
    }
    return false
  }

}