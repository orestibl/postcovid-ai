import 'package:android_long_task/long_task/service_data.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class AppClient {
  static const CHANNEL_NAME =
      "FSE_APP_CHANNEL_NAME"; // Para comunicarme con AndroidLongTask
  static const START_SERVICE = "START_SERVICE";
  static const SET_INITIAL_SERVICE_DATA =
      "SET_INITIAL_SERVICE_DATA"; //hector, lo cambio a "_initial"
  static const IS_SERVICE_RUNNING = "IS_SERVICE_RUNNING";
  static const GET_SERVICE_DATA = "GET_SERVICE_DATA";
  static const STOP_SERVICE = "STOP_SERVICE";
  static const RUN_DART_FUNCTION = "RUN_DART_FUNCTION";
  static const INVOKE_RUN_DART_CODE = "INVOKE_RUN_DART_CODE";
  static const NOTIFY_UPDATE = "NOTIFY_UPDATE";
  static const APP_DETACHED = "APP_DETACHED";
  static const APP_PAUSED = "APP_PAUSED";
  static const APP_RESUMED = "APP_RESUMED";
  static final _serviceDataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final MethodChannel channel = MethodChannel(CHANNEL_NAME)
    ..setMethodCallHandler((call) async {
      print(
          "HH_MethodCallHandler de $CHANNEL_NAME app_client.dart: ${call.method}-> ${call.arguments?.toString()}");
      if (call.method == NOTIFY_UPDATE) {
        var stringData = call.arguments as String;
        print("HH_Recibido NOTIFY_UPDATE");
        if (_serviceDataStreamController.hasListener) {
          if (stringData == null)
            _serviceDataStreamController.sink.add(null);
          else {
            Map<String, dynamic> json = jsonDecode(stringData);
            _serviceDataStreamController.sink.add(json);
          }
        } else
          print("HH_no envío este evento porque no tengo listeners");
      }
    });

  static Future<void> startService(ServiceData initialData) async {
    print(
        "HH_ app_client.dart: startService. Invocando SET_INITIAL_SERVICE_DATA");
    if (initialData != null) {
      await channel.invokeMethod(
          SET_INITIAL_SERVICE_DATA, ServiceDataWrapper(initialData).toJson());
    }
    print(
        "HH_ app_client.dart: startService: si el servicio no existe, inicia el nuevo servicio y lo une a AndroidLognTask.kt. Si existe, solo une el servicio ya existe a AndroidLognTask.kt");
    await channel.invokeMethod(START_SERVICE);
  }

  static Future<void> stopService() async {
    print("HH_ app_client.dart: stopService");
    await channel.invokeMethod(STOP_SERVICE);
  }

  static Future<void> sendAppDetached() async {
    // no es necesario, desde el plugin se gestiona esto
    print("HH_ app_client.dart: sendAppDetached");
    await channel.invokeMethod(APP_DETACHED);
  }

  static Future<void> sendAppPaused() async {
    print("HH_ app_client.dart: sendAppPaused");
    await channel.invokeMethod(APP_PAUSED);
  }

  static Future<void> sendAppResumed() async {
    print("HH_ app_client.dart: sendAppResumed");
    await channel.invokeMethod(APP_RESUMED);
  }

  static Future<void> prepareExecute() async {
    // print(
    //     "HH_ app_client.dart: prepareExecute. Invocando SET_INITIAL_SERVICE_DATA");
    // await channel.invokeMethod(
    //     SET_INITIAL_SERVICE_DATA, ServiceDataWrapper(initialData).toJson());
    // print("HH_ app_client.dart: OJO, AHORA YA SE SE INVOCA START_SERVICE AQUÍ: DEBES HACERLO ANTES LLAMANDO A startService!!!");
    // print("HH_ app_client.dart: prepareExecute. Invocando START_SERVICE");
    // await channel.invokeMethod(START_SERVICE);
    print("HH_ app_client.dart: execute. Invocando RUN_DART_FUNCTION.");
    await channel.invokeMethod(RUN_DART_FUNCTION, "");
  }

  // Se ha dividido esto en dos para facilitar que dé tiempo en serviceMain() para crear los callbacks de su canal y así estar ya preparado cuando ahora se haga el invokeMethod
  // static Future<Map<String, dynamic>> execute() async {
  //   print(
  //       "HH_ app_client.dart: execute. Invocando INVOKE_RUN_DART_CODE.");
  //   var result = await channel.invokeMethod(INVOKE_RUN_DART_CODE, "");
  //   Map<String, dynamic> json = jsonDecode(result as String);
  //   return json;
  // }
  static void execute() {
    print(
        "HH_ app_client.dart: execute. Invocando INVOKE_RUN_DART_CODE. NO CREO QUE SEA BUENA IDEA ESPERAR AL RESULTADO NI HACER NADA CON ÉL!!!! --> no devuelvo nada");
    channel.invokeMethod(INVOKE_RUN_DART_CODE, ""); //ni async ni await ni nada
  }
  // static Future<void> setInitialData(ServiceData serviceData) async {
  //   await channel.invokeMethod(_SET_INITIAL_SERVICE_DATA, ServiceDataWrapper(serviceData).toJson());
  // }

  static Future<Map<String, dynamic>> getData() async {
    print("HH_app_client.dart, getData con timeout");
    var stringData = await channel
        .invokeMethod(GET_SERVICE_DATA)
        .timeout(const Duration(milliseconds: 1000), onTimeout: () {
      print("getData TIMEOUT!!!");
      return null;
    });
    print("HH_app_client.dart, getData: stringData=$stringData");
    if (stringData == null) return null;
    Map<String, dynamic> json = jsonDecode(stringData);
    return json;
  }

  static Stream<Map<String, dynamic>> get observe {
    print("HH_ app_client.dart get observe");
    try {
      //dirty fix
      getData(); // se lanza esta hebra pero no nos importa lo que devuelva. Pero así parece que se inicializa el stream
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    return _serviceDataStreamController.stream;
  }

  // isServiceRunning. Ten en cuenta que la app puede re-entrar cuando la long task ya está en ejecución
  // --> no basta con tener una variable que inicialmente esté en false.
  static Future<bool> isServiceRunning() async {
    print("HH_ app_client.dart: isServiceRunning");
    String result = await channel.invokeMethod(IS_SERVICE_RUNNING).timeout(
      const Duration(milliseconds: 2000),
      onTimeout: () {
        print("TIMEOUT!!! We return false");
        return "NO"; //El return se refiere al valor de result y no al de isServiceRunning
      },
    );

    if (result == "YES") {
      print("We return true");
      return true;
    }
    print("We return false");
    return false;
  }
}
