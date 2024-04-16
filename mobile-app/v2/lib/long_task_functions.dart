import 'dart:async';
import 'dart:convert';

import 'package:android_long_task/long_task/app_client.dart';
import 'package:android_long_task/long_task/service_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'main.dart';
import 'my_logger.dart';

/// LONG TASK-RELATED FUNCTIONS ////

StreamSubscription<Map<String, dynamic>?>? getLongTaskStreamSubscription() {
  try {
    return AppClient.updates.listen((json) {
      //if (mounted) {
      //var serviceData = AppServiceData.fromJson(json);
      // setState(() {
      try {
        debugPrint("AppClient recibe lo siguiente: ${json.toString()}");
        String uuid = json?['uuid'] ?? 'unknown';
        String watchdog = json?['watchdog'] ?? '';
        if (watchdog.isNotEmpty) {
          lastWatchDogReceivedByUuid[uuid] = watchdog;
          lastWatchDogReceivedByUuid['any'] =
              watchdog; // si no sé el uuid de la longtask, aquí guardo el último recibido por cualquier uuid
        }
      } catch (e) {
        debugPrint("Algo pasa en el listener de AppClient!!!");
      }

      // _status = serviceData.notificationDescription;
      // miTexto = miTexto + "\n" + _status;
      // });
      // }
    });
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
    return null;
  }
}

class AppServiceData extends ServiceData {
  int progress = -1;
  String watchdog = '';
  String uuid = ''; // para identificar a la long_task (aunque no debes tener más de una ya que los mensajes solo llegarían a la
  // última -> tendrías que usar shared_prefs con este uuid para acceder a a una concreta
  String mensaje = ''; // el mensaje a sacar en la notificación
  // Desde la long task deben cambiar el contenido watchdog para que el usuario vea que se ha cargado correctamente
  String miNotificationTitle = "POSTCOVID-AI: Pulsar aquí si no se inicializa solo";

  @override
  String toJson() {
    var jsonMap = {
      'progress': progress,
      'watchdog': watchdog,
      'mensaje': mensaje,
      'uuid': uuid,
    };
    return jsonEncode(jsonMap);
  }

  static AppServiceData fromJson(Map<String, dynamic> json) {
    return AppServiceData()
      ..progress = (json['progress'] as int)
      ..mensaje = (json['mensaje'] as String)
      ..uuid = (json['uuid'] as String)
      ..watchdog = (json['watchdog'] as String);
  }

  // Esto es lo que saldrá en la barra de notificación (no hace falta que se transfiera a la app -> no pongo esa variable en toJson y fromJson)
  @override
  String get notificationTitle {
    //debugPrint("miNotificationTitle= $miNotificationTitle");
    return miNotificationTitle;
  }

  @override
  String get notificationDescription => mensaje;
  // String get notificationDescription => 'Universidad de Granada';
}

Future<void> startService(AppServiceData? appServiceData) async {
  try {
    await AppClient.startService(appServiceData);
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
  }
}

Future<bool> isServiceRunning() async {
  try {
    return await AppClient.isServiceRunning();
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
    return false;
  }
}

Future<bool> isServiceClientListening() async {
  try {
    return await AppClient.isServiceClientListening();
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
    return false;
  }
}

Future<void> prepareLongTask(AppServiceData appServiceData) async {
  // preparo todo para poder ejecutar la long task
  // si hay otra long task previamente ejecutándose, es el usuario el que
  // debería verificarlo antes de llamar a esta función (es imposible saberlo
  // desde aquí porque pueden ocurrir muchas cosas: servicio on pero bucle long task
  // off aunque responda a myEndDartCode, etc.).
  // Aparte del hecho de que se puede querer ejecutar varias long tasks en paralelo) -> pero los mensajes a la long_task solo van a llegar a la última!!! P.ej. "endDartCode"
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appServiceData.mensaje = packageInfo.packageName;
    await AppClient.startService(appServiceData);
    await AppClient.prepareExecute();
    // debugPrint(
    //     "HH_DUERMO unos ms en main.dart antes de AppClient.execute() para dejar que se ejecute serviceMain del todo y cree los callbacks de su canal");
    // sleep(Duration(milliseconds: 500));
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
  }
}

Future<Map<String, dynamic>?> getDataMessage() async {
  try {
    var result = await AppClient.getData();
    return result;
  } on PlatformException catch (e, stacktrace) {
    if (kDebugMode) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }

    return null;
  }
}

Future<void> runLongTask() async {
  // if (await isLongTaskRunning()) {
  //   milog.shout(
  //       "Long task already running. It is a bad idea to run it again now!");
  //   return;
  // }
  // miLongTaskStreamSubscription = getLongTaskStreamSubscription();
  // AppClient.sendAppResumed();
  try {
    AppClient.execute();
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
  }
}

Future<void> stopLongTask({stopServiceToo = true}) async {
  try {
    debugPrint("HH_ INICIO: stopLongTask: endDartCode");
    await AppClient.endDartCode();
  } on PlatformException catch (e, stacktrace) {
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
  }
  debugPrint("HH_ FIN: stopLongTask: endDartCode");
  if (stopServiceToo) {
    await Future.delayed(const Duration(seconds: NUM_SECONDS_MAIN_LOOP_LONG_TASK));
    try {
      debugPrint("HH_ INICIO: stopLongTask: stopService");
      await AppClient.stopService();
      //setState(() => _result = 'stop service');
    } on PlatformException catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
    debugPrint("HH_ FIN: stopLongTask: stopService");
  }
}
