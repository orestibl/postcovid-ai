// Esta función la usa tanto la UI como la long_task -> quizás mejor ponerla en otro sitio
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_long_task/long_task/service_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:postcovid_ai_sin_carp/src/carp_backend/carp_backend_modificado.dart';
import 'package:postcovid_ai_sin_carp/src/default/study2/study_surveys_default.dart';
import 'package:postcovid_ai_sin_carp/src/helper_functions.dart';
import 'package:postcovid_ai_sin_carp/src/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'credentials.dart';
import 'main.dart';
import 'my_logger.dart';
import './src/strings.dart';

/// Foreground service main
@pragma('vm:entry-point')
serviceMain2() async {
  WidgetsFlutterBinding.ensureInitialized();
  // variables "globales" que usa más de una función
  if (IGNORAR_CERTIFICADO_SSL) HttpOverrides.global = MyHttpOverrides();
  bool uiPresent = true;
  bool salimos = false;
  var currentTime = DateTime.now();
  // esta variable es para asegurarnos de que por algún error uiPresent no se quede en true demasiado tiempo
  // es raro que el usuario haya mantenido la app activa más de MAX_SECONDS_SEGUIDOS_UI_PRESENT segundos
  // ten en cuenta que aquí ya se entra una vez que se ha metido el código válido y
  // ha contestado el consentimiento informado y la initial survey.
  var lastTimeUiStartedPresent = currentTime;
  // Stream<ActivityEvent> activityStream;
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    MyLogger.listen(record, useColors: true, showLevelName: true, showTime: true);
  });
  // Puedes usar milog.shout para enviar mensajes al servidor. En my_logger.dart
  // esa función está blindada para tragarse la excepción que surja y tiene un timeout
  final Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool conectado = true;
  int lastTimeConnectivityNone = -1;
  int lastTimeConnectivityOk = -1;

  Future<dynamic> myEndDartCode() async {
    milog.info("HH_main.dart myEndDartCode INI. uuid = $longTaskUuid");
    // milog.info("HH_main.dart myEndDartCode INI");
    // if (bloc.isRunning) {
    //   bloc.pause();
    // }
    unawaited(connectivitySubscription?.cancel());
    unawaited(cancelaListeners());
    salimos = true;
  }

  Future<dynamic> myUiPresentCode() async {
    uiPresent = true;
    milog.info("Ui Present = True");
    lastTimeUiStartedPresent = currentTime;
    // aquí puedes aprovechar para enviar algo a través de appServiceData.progress
    // appServiceData.progress = 10000;
    // ServiceClient.update(appServiceData);
  }

  Future<dynamic> myUiNotPresentCode() async {
    uiPresent = false;
    milog.info("Ui Present = False");
    // appServiceData.progress = -10000;
    // ServiceClient.update(appServiceData);
  }

  Future<dynamic> myDartCode(Map<String, dynamic> initialData) async {
    milog.info("Ejecutando myDartCode. initialData=${initialData.toString()}");

    // ///////////////////
    // milog.severe("borra esto!!!");
    // int i = 0;
    // longTaskUuid = initialData['uuid'] ?? "";
    // while (true) {
    //   if (salimos) {
    //     milog.info("uuid = $longTaskUuid, salimos!!");
    //     break;
    //   }
    //   await Future.delayed(const Duration(seconds: 10));
    //   milog.info("uuid = $longTaskUuid, i = $i");
    //   appServiceData.watchdog = currentTime.toIso8601String();
    //   appServiceData.mensaje = "appServiceData.mensaje: uuid = $longTaskUuid";
    //
    //   // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
    //   await ServiceClient.update(appServiceData);
    //   i++;
    // }
    // return;
    // //////////////

    // ******************* VARIABLES E INICIALIZACIONES *****************

    var numItLongTask = 0;
    uiPresent = true;
    bool desaceleraPeriodoBuclePrincipalPorPendingSurvey = false;
    SharedPreferences? prefs;
    String code = "";
    String deviceInfo = "";
    bool deviceIdUploaded = false;
    Map<dynamic, dynamic>? studyCredentials;

    List<dynamic>? surveys;
    String surveysJson;

    final dateStartLongTask = currentTime; // solo para depurar si usamos acelerarTiemposParaDepurarSurveys
    final cadenaHoraInicio = "${currentTime.hour}:${currentTime.minute}";
    final cadenaFechaInicio = "${currentTime.day}/${currentTime.month}/${currentTime.year}";
    final miNotificationTitle = "${Strings.appName} iniciada: $cadenaHoraInicio $cadenaFechaInicio";
    DateTime datePendingSurvey = DateTime(2000); //1 de enero de 2000 -> claramente pasado
    var pendingSurvey = false;
    int hourPendingSurvey = 0;
    int pendingSurveyID = 3;
    appServiceData.miNotificationTitle = miNotificationTitle;
    longTaskUuid = initialData['uuid'] ?? ""; //si no existe, se queda en null
    appServiceData.uuid = longTaskUuid;

    int lastTimeSurveyCheck = currentTime.millisecondsSinceEpoch;
    int lastTimeWatchDog = -1;
    int lastTimeSelfKill = -1;
    int lastTimeLight = -1;
    int lastTimeNoise = -1;
    // cuanto antes enviamos el watch_dog porque si no, el programa principal puede que intente volver a llamar a esta función
    try {
      appServiceData.watchdog = currentTime.toIso8601String();
      if (MOSTRAR_INFO) {
        appServiceData.mensaje = "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
      } else {
        appServiceData.mensaje = Strings.appOk;
      }

      // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
      await ServiceClient.update(appServiceData).timeout(timeoutValue);
      milog.info("Primer watchdog enviado a través de ServiceClient");
      prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOG_WATCH_DOG, currentTime.toIso8601String()).timeout(timeoutValue);
      milog.info("Primer watchdog enviado a través de $LOG_WATCH_DOG");
      lastTimeWatchDog = currentTime.millisecondsSinceEpoch;
      // aquí no pasa nada si no funciona (se usa serviceData normalmente)
      await prefs.setString(LOG_WATCH_DOG, currentTime.toIso8601String()).timeout(timeoutValue);
    } catch (e, s) {
      milog.shout("Error al hacer setString de LOG_WATCH_DOG: ${e.toString()} ${s.toString()}");
    }
    int lastTimeSurveysSchedulingDownloaded = lastTimeSurveyCheck;
    int lastTimeDocumentsDownloaded = lastTimeSurveyCheck;

    int offsetMinutoSurvey = Random().nextInt(MAX_OFFSET_MINUTOS_SURVEY + 1);

    milog.info("Las encuestas se contestarán a partir de las 'y $offsetMinutoSurvey' minutos");

    final FlutterLocalNotificationsPlugin fsNotificationService = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails('surveyChannelID', 'surveyChannel',
        channelDescription: 'Survey Channel',
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showWhen: false,
        visibility: NotificationVisibility.public);

    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    var sdkVersion = -1;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      sdkVersion = info.version.sdkInt;
    } catch (e) {
      debugPrint("Error al obtener sdkVersion. No es importante: ${e.toString()}");
    }
    if (CHECK_SDK_VERSION_TO_REMOVE_NOISE_METER && sdkVersion >= 30) {
      // no grabamos el audio. Solo se puede hacer en foreground y eso sucede muy pocas veces -> es un riesgo innecesario
      USE_NOISE_METER = false;
    }
    //var connectivityListenerLocked = false;
    // ******************* INICIALIZACIONES CON AWAITS QUE NO PUEDEN FALLAR *****************
    // INICIALIZACIONES ANTES DE ENTRAR EN EL BUCLE -> OJO, ESTO NO PUEDE FALLAR!!! -> BUCLE INFINITO HASTA QUE FUNCIONE!!!
    while (true) {
      if (salimos) break;
      // si esto falla no podemos seguir...
      try {
        prefs ??= await SharedPreferences.getInstance();
        code = prefs.getString(SHARED_CODE) ?? "";
        if (code != "" && code.length == 10) {
          break;
        }
      } catch (e, s) {
        final mensaje = "Error al hacer SharedPreferences.getInstance o no existe code o no son 10 letras: ${e.toString()} ${s.toString()}";
        milog.shout(mensaje);
      }
      await Future.delayed(timeoutValue);
    }
    final studyCode = code.substring(5, 10);
    if (prefs != null) {
      // En la inicialización desde la app se pone este valor -> debería estar
      surveysJson = prefs.getString(SHARED_STUDY_SURVEYS) ?? "";
      if (surveysJson != "") {
        surveys = jsonDecode(surveysJson);
      } else {
        surveys = jsonDecode(defaultStudySurveysJson);
        milog.shout("No puedo obtener surveys correctamente!!! Uso los valores por defecto.");
        await prefs.setString(SHARED_STUDY_SURVEYS, defaultStudySurveysJson).timeout(timeoutValue);
        // en ese caso, hay que forzar la actualización cuanto antes.
        // Como está puesto:
        // currentTime.millisecondsSinceEpoch - lastTimeSurveysSchedulingDownloaded > deltaSurveysDownload
        // y no ">=", esto lo haré en la segunda iteración de comprobación de surveys
        // (mejor en la segunda que en la primera)
        lastTimeSurveysSchedulingDownloaded = lastTimeSurveysSchedulingDownloaded - DELTA_SURVEYS_SCHEDULING_DOWNLOAD;
      }
    }
    try {
      // Esto no tendría por qué no funcionar: obtenemos deviceIdUploaded y deviceInfo
      deviceIdUploaded = prefs?.containsKey(SHARED_IS_DEVICE_ID_UPLOADED) ?? false;
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      deviceInfo = info.id;
    } catch (e, s) {
      milog.shout("Error al hacer DeviceInfoPlugin().androidInfo: ${e.toString()} ${s.toString()}");
    }
    try {
      // aquí no es tan grave si no funciona. Pero hay que quitar alguna survey
      // que se haya quedado de cuando se apagó la última vez
      if (prefs != null) {
        await prefs.remove(SHARED_SURVEY_ID);
      }
    } catch (e, s) {
      milog.shout("Error al hacer prefs.remove(SHARED_SURVEY_ID): ${e.toString()} ${s.toString()}");
    }
    //final List<int> completedSurveys = new List<int>.from(jsonDecode(prefs.getString(SHARED_COMPLETED_SURVEYS))) ??  List<int>.filled(24, -1);
    List<int> completedSurveys; //más robusto así
    if (prefs != null && prefs.containsKey(SHARED_COMPLETED_SURVEYS)) {
      try {
        completedSurveys = List<int>.from(jsonDecode(
            prefs.getString(SHARED_COMPLETED_SURVEYS) ?? "[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]"));
      } catch (e, s) {
        milog.shout("Error al hacer jsonDecode de completedSurveys: ${e.toString()} ${s.toString()}");
        completedSurveys = List.filled(24, -1);
      }
    } else {
      completedSurveys = List.filled(24, -1);
      if (INICIALIZAR_INITIAL_SURVEY_COMO_WEEKLY_SURVEY) {
        completedSurveys[HORA_WEEKLY_SURVEY] = currentTime.millisecondsSinceEpoch;
      }
    }
    // Inicializo el listener de connectivity
    //
    connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        // MUCHO OJO, ESTE CÓDIGO PUEDE RE-ENTRAR EN CUESTIÓN DE ms
        // Puedes poner un lock (que deberías activar siempre en el "finally" del
        // try-catch-finally
        // Pero a mí me interesa solo si me quedo sin conexión.
        // Así que no puedo perder cuando te llegue ese "result"
        // En el resto de los casos, es muy rápido -> la re-entrada no creo que afecte
        // En el bucle principal miro si la hemos recuperado para re-arrancar el bloc
        // Es lo mejor para no tener que estar parando y arrancando el bloc
        // con mucha frecuencia
        try {
          debugPrint("HECTOR: CAMBIO EN LA RED: ${result.toString()}");
          if (result == ConnectivityResult.none) {
            conectado = false;
            lastTimeConnectivityNone = DateTime.now().millisecondsSinceEpoch;
            if (MOSTRAR_INFO) {
              appServiceData.mensaje = "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
              // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
              await ServiceClient.update(appServiceData).timeout(timeoutValue);
            }
          }
        } catch (e) {
          final mensaje = "HECTOR: Error en el listener de Connectivity:  ${e.toString()}\n";
          debugPrint(mensaje);
          // Pero no hacemos nada más
        } finally {
          //connectivityListenerLocked = false;
        }
      },
    );
    await arrancaListeners(code: code, deviceInfo: deviceInfo);

    // ******************* BUCLE PRINCIPAL *****************
    await Future.delayed(const Duration(seconds: DELAY_ANTES_BUCLE_PRINCIPAL_LONG_TASK));
    String ultimoMensaje = "";
    while (true) {
      // el primer currentTime ya lo he obtenido en la inicialización. Al final del bucle obtengo un nuevo valor.
      // hay que blindar el código: no puede dejar de funcionar!!!
      try {
        numItLongTask += 1;
        milog.info('dart -> $numItLongTask');
        appServiceData.progress = numItLongTask;
        // SI ESTÁBAMOS SIN RED Y HA PASADO UN TIEMPO PRUDENCIAL, COMPRUEBO SI LA HEMOS RECUPERADO
        // Esto lo prefiero a hacerlo inmediatamente con el listener de connectivity, porque a veces
        // está la red inestable y se llama demasiadas veces. Ten en cuenta que tener conexión no quiere
        // decir que funcione Internet ni que el servidor esté operativo
        if (!conectado) {
          if (currentTime.millisecondsSinceEpoch - lastTimeConnectivityNone > DELTA_RECHECK_CONNECTIVITY) {
            // para no volver a comprobarlo hasta que pasen DELTA_RECHECK_CONNECTIVITY segundos
            // Fíjate que aunque al final detectemos que hay red, da igual que lastTimeConnectivityNone
            // la hayamos actualizado ya que solo se volverá a leer cuando volvamos a poner
            // conectado = false, y cuando hacemos eso volvemos a actualizar lastTimeConnectivityNone
            lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
            if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
              // es posible que tengamos acceso al servidor
              if (await isHostReachable() && await isServerResponding()) {
                // Volvemos a tener acceso al servidor
                conectado = true;
                lastTimeConnectivityOk = currentTime.millisecondsSinceEpoch;
                if (MOSTRAR_INFO) {
                  appServiceData.mensaje =
                      "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
                } else {
                  appServiceData.mensaje = Strings.appOk;
                }
                // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
                ultimoMensaje = "ServiceClient.update1";
                await ServiceClient.update(appServiceData).timeout(timeoutValue);
              }
            }
          }
        } else {
          // Estamos conectados, pero a lo mejor hemos perdido la conexión con el servidor
          if (currentTime.millisecondsSinceEpoch - lastTimeConnectivityOk > DELTA_CHECK_SERVER_CONNECTED) {
            // Igual que he puesto antes, lo actualizo incluso aunque al final resulte
            // que no hay conexión con el servidor. Porque en ese caso, pondremos
            // conectado = false y cuando se ponga a true se actualizará lastTimeConnectivityOk
            lastTimeConnectivityOk = currentTime.millisecondsSinceEpoch;
            if (!await isHostReachable() || !await isServerResponding()) {
              // UPS!!! Estamos conectados pero no tenemos acceso a Internet o al servidor
              conectado = false;
              lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
              if (MOSTRAR_INFO) {
                appServiceData.mensaje = "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
              } else {
                appServiceData.mensaje = Strings.appOk;
              }
              // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
              ultimoMensaje = "ServiceClient.update2";
              await ServiceClient.update(appServiceData).timeout(timeoutValue);
            } else if (prefs != null) {
              // aprovecho para mirar el time_zone. Si hay algún cambio, lo notifico al servidor (que sé que ahora está "vivo")
              try {
                final oldTimeZone = prefs.getString(SHARED_TIME_ZONE) ?? "";
                final newTimeZone = currentTime.timeZoneName;
                if (oldTimeZone != newTimeZone) {
                  milog.info("Actualizamos time zone: $oldTimeZone -> $newTimeZone");
                  // No hago milog.shout porque necesitamos asegurarnos de que el servidor recibe newTimeZone (si no, ya lo intentaremos la siguiente iteración)
                  final response = await sendLogToServer("TimeZone: $newTimeZone");
                  if (response == 200) {
                    // el servidor lo ha recibido correctamente, actualizamos el valor en las prefs compartidas
                    prefs.setString(SHARED_TIME_ZONE, newTimeZone);
                  }
                }
              } catch (e) {
                milog.shout("Error al actualizar SHARED_TIME_ZONE: ${e.toString()}");
              }
            }
          }
        }
        ////////////////////// Tareas urgentes a realizar (si estamos conectados) cuanto antes!!! //////////////////////
        // Posibles tareas pendientes: studyCredentials==null, deviceUploaded==false, SHARED_SURVEY_PENDING_TO_BE_SENT, SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT,
        // SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT, listaEventos llena
        if (conectado) {
          if (studyCredentials == null) {
            if ((await Connectivity().checkConnectivity() != ConnectivityResult.none) &&
                await isHostReachable() &&
                await isServerResponding()) {
              try {
                ultimoMensaje = "getStudyFromAPIREST";
                studyCredentials = await getStudyFromAPIREST(code).timeout(timeoutValue);
              } catch (e) {
                milog.shout("Fallo al hacer getStudyFromAPIREST. code = $code, e=${e.toString()}");
              }
            } else {
              // si no se ha podido recibir -> no hay conexión -> actualizo la variable "conectado"
              conectado = false;
              lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
              if (MOSTRAR_INFO) {
                appServiceData.mensaje = "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
              } else {
                appServiceData.mensaje = Strings.appOk;
              }
              // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
              ultimoMensaje = "ServiceClient.update3";
              await ServiceClient.update(appServiceData).timeout(timeoutValue);
            }
          }
        }
        if (conectado) {
          if (!deviceIdUploaded) {
            try {
              ultimoMensaje = "storeUser";
              deviceIdUploaded = await storeUser(code, checkConnection: true).timeout(timeoutValue);
            } catch (e) {
              milog.shout("storeUser devuelve excepción");
            }
          }
        }
        if (conectado) {
          if (prefs != null && prefs.containsKey(SHARED_SURVEY_PENDING_TO_BE_SENT)) {
            milog.info("SHARED_SURVEY_PENDING_TO_BE_SENT: Hay que enviar esta encuesta!!!");
            final surveyToBeSent = prefs.getString(SHARED_SURVEY_PENDING_TO_BE_SENT) ?? "";
            if (surveyToBeSent != "") {
              final success = await sendJsonEncodedDataPoint(surveyToBeSent, studyCredentials: studyCredentials, checkConnection: true);
              if (success) {
                try {
                  // DataPoint data = DataPoint.fromJson(jsonDecode(surveyToBeSent));
                  // await CarpService().getDataPointReference().postDataPoint(data);
                  await prefs.remove(SHARED_SURVEY_PENDING_TO_BE_SENT).timeout(const Duration(seconds: 10));
                } catch (e, s) {
                  milog.shout("Error al hacer prefs.remove(SHARED_SURVEY_PENDING_TO_BE_SENT) ${e.toString()} ${s.toString()}");
                }
              } else {
                // si no se ha podido enviar -> no hay conexión -> actualizo la variable "conectado"
                conectado = false;
                lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
                if (MOSTRAR_INFO) {
                  appServiceData.mensaje =
                      "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
                } else {
                  appServiceData.mensaje = Strings.appOk;
                }
                // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
                ultimoMensaje = "ServiceClient.update4";
                await ServiceClient.update(appServiceData).timeout(timeoutValue);
              }
            }
          }
        }
        if (conectado) {
          if (prefs != null && prefs.containsKey(SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT)) {
            milog.info("SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT: Hay que enviar esta encuesta!!!");
            final surveyToBeSent = prefs.getString(SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT) ?? "";
            if (surveyToBeSent != "") {
              final success = await sendJsonEncodedDataPoint(surveyToBeSent, studyCredentials: studyCredentials, checkConnection: true);
              if (success) {
                try {
                  // DataPoint data = DataPoint.fromJson(jsonDecode(surveyToBeSent));
                  // await CarpService().getDataPointReference().postDataPoint(data);
                  await prefs.remove(SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT).timeout(const Duration(seconds: 10));
                } catch (e, s) {
                  milog.shout("Error al hacer prefs.remove(SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT) ${e.toString()} ${s.toString()}");
                }
              } else {
                // si no se ha podido enviar -> no hay conexión -> actualizo la variable "conectado"
                conectado = false;
                lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
                if (MOSTRAR_INFO) {
                  appServiceData.mensaje =
                      "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
                } else {
                  appServiceData.mensaje = Strings.appOk;
                }
                // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
                ultimoMensaje = "ServiceClient.update5";
                await ServiceClient.update(appServiceData).timeout(timeoutValue);
              }
            }
          }
        }
        if (conectado) {
          if (prefs != null && prefs.containsKey(SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT)) {
            milog.info("SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT: Hay que enviar esta encuesta!!!");
            final surveyToBeSent = prefs.getString(SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT) ?? "";
            if (surveyToBeSent != "") {
              final success = await sendJsonEncodedDataPoint(surveyToBeSent, studyCredentials: studyCredentials, checkConnection: true);
              if (success) {
                try {
                  // DataPoint data = DataPoint.fromJson(jsonDecode(surveyToBeSent));
                  // await CarpService().getDataPointReference().postDataPoint(data);
                  await prefs.remove(SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT).timeout(const Duration(seconds: 10));
                } catch (e, s) {
                  milog.shout("Error al hacer prefs.remove(SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT) ${e.toString()} ${s.toString()}");
                }
              } else {
                // si no se ha podido enviar -> no hay conexión -> actualizo la variable "conectado"
                conectado = false;
                lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
                if (MOSTRAR_INFO) {
                  appServiceData.mensaje =
                      "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
                } else {
                  appServiceData.mensaje = Strings.appOk;
                }
                // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
                ultimoMensaje = "ServiceClient.update6";
                await ServiceClient.update(appServiceData).timeout(timeoutValue);
              }
            }
          }
        }
        if (conectado) {
          if (prefs != null && prefs.containsKey(SHARED_DATA_POINTS_TO_BE_SENT)) {
            milog.info("SHARED_DATA_POINTS_TO_BE_SENT: Hay que enviar estos datos!!!");
            final dataPointsToBeSent = prefs.getStringList(SHARED_DATA_POINTS_TO_BE_SENT) ?? [];
            if (dataPointsToBeSent.isNotEmpty) {
              // HECTOR: No sé si crear una función para llamarla de forma unawaited y que se encargue de esto
              // Por otro lado, si da un error va a poner conectado = false y no vamos a enviarlo inmediatamente...
              // Solución: enviar solo BATCH_MAX_NUM_DATA_POINTS_TO_BE_SENT en cada intento
              List<String> finalDataPointsToBeSent = [];
              List<String> finalDataPointsToBeLeft = [];
              bool cabeTodo = false;
              if (dataPointsToBeSent.length <= BATCH_MAX_NUM_DATA_POINTS_TO_BE_SENT) {
                finalDataPointsToBeSent = dataPointsToBeSent;
                cabeTodo = true;
              } else {
                for (int i = 0; i < BATCH_MAX_NUM_DATA_POINTS_TO_BE_SENT; i++) {
                  finalDataPointsToBeSent.add(dataPointsToBeSent[i]);
                }
                for (int i = BATCH_MAX_NUM_DATA_POINTS_TO_BE_SENT; i < dataPointsToBeSent.length; i++) {
                  finalDataPointsToBeLeft.add(dataPointsToBeSent[i]);
                }
              }
              final success =
                  await sendJsonEncodedDataPointsBatch(finalDataPointsToBeSent, studyCredentials: studyCredentials, checkConnection: true);
              if (success) {
                milog.info("Batch enviado con éxito!!!");
                try {
                  if (cabeTodo) {
                    // una vez me dio un timeout cuando le ponía 1s -> le pongo 10s a todos los .remove
                    await prefs.remove(SHARED_DATA_POINTS_TO_BE_SENT).timeout(const Duration(seconds: 10));
                  } else {
                    //no pongo timeout por si es muy gorda -> al menos pongo 300s que es lo máximo que puedo esperar
                    ultimoMensaje = "SHARED_DATA_POINTS_TO_BE_SENT";
                    await prefs.setStringList(SHARED_DATA_POINTS_TO_BE_SENT, finalDataPointsToBeLeft).timeout(const Duration(seconds: 300));
                  }
                } catch (e, s) {
                  milog.shout("Error al hacer prefs.remove(SHARED_DATA_POINTS_TO_BE_SENT) ${e.toString()} ${s.toString()}");
                }
              } else {
                // si no se ha podido enviar -> no hay conexión -> actualizo la variable "conectado"
                conectado = false;
                lastTimeConnectivityNone = currentTime.millisecondsSinceEpoch;
                if (MOSTRAR_INFO) {
                  appServiceData.mensaje =
                      "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado";
                } else {
                  appServiceData.mensaje = Strings.appOk;
                }
                // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
                ultimoMensaje = "ServiceClient.update7";
                await ServiceClient.update(appServiceData).timeout(timeoutValue);
              }
            }
          }
        }
        if ((prefs != null) && (listaDataPoints.length > MIN_NUM_DATA_POINTS_TO_BE_STORED)) {
          milog.info("Vamos a guardar la lista de data points en las shared_prefs y la reseteamos");
          var listaPrevia = prefs.getStringList(SHARED_DATA_POINTS_TO_BE_SENT) ?? [];
          final listaNueva = listaPrevia + listaDataPoints;
          milog.info("La lista nueva ahora tiene tamaño: ${listaNueva.length}");
          // debugPrintWrapped("ListaNueva = ${listaNueva.toString()}");
          listaDataPoints = [];
          //no pongo timeout por si es muy gorda -> al menos pongo 300s que es lo máximo que puedo esperar
          ultimoMensaje = "SHARED_DATA_POINTS_TO_BE_SENT2";
          await prefs.setStringList(SHARED_DATA_POINTS_TO_BE_SENT, listaNueva).timeout(const Duration(seconds: 300));
        }
        //////////////////  WATCHDOG DE LAS SHARED PREFS (EL DE LAS NOTIFICACIONES SE HACE EN CADA ITERACIÓN DEL BUCLE, TRAS EL Future.delayed//////////////////////
        if (currentTime.millisecondsSinceEpoch - lastTimeWatchDog > DELTA_WATCH_DOG_CHECK) {
          try {
            final watchDogTime = currentTime.toIso8601String();
            milog.info("appendLogDataWatchDog: añadiendo $watchDogTime");
            if (prefs != null) {
              ultimoMensaje = "LOG_WATCH_DOG";
              await prefs.setString(LOG_WATCH_DOG, watchDogTime).timeout(timeoutValue);
            }
            lastTimeWatchDog = currentTime.millisecondsSinceEpoch;
            // para mantener la conexión viva... (no sé si esto es importante)
            // no merece la pena esperar a que termine (await). Sí que lo debes hacer para que esté dentro del try-catch
            ultimoMensaje = "ServiceClient.sendAck";
            await ServiceClient.sendAck().timeout(timeoutValue);
          } catch (e, s) {
            milog.shout("Error al hacer update: ${e.toString()} ${s.toString()}");
          }
        }
        ////////////////////////  SELF KILL //////////////////////
        if (longTaskUuid.length > 5 && currentTime.millisecondsSinceEpoch - lastTimeSelfKill > DELTA_SELF_KILL_CHECK) {
          try {
            if (prefs != null) {
              ultimoMensaje = "SELF KILL CHECK";
              final uuidToBeKilled = prefs.getStringList(SHARED_LT_UUID_LIST_TO_BE_KILLED) ?? [];
              if (uuidToBeKilled.contains(longTaskUuid)) {
                // Se supone que lo habrán intentado de otra forma, pero este es un caso muy muy excepcional
                // Debemos acabar
                milog.shout("Recibo self kill: uuid = $longTaskUuid");
                await myEndDartCode().timeout(timeoutValue);
              }
            }
            lastTimeSelfKill = currentTime.millisecondsSinceEpoch;
          } catch (e, s) {
            milog.shout("Error en self kill check: ${e.toString()} ${s.toString()}");
            // salimos a lo bestia
            unawaited(connectivitySubscription?.cancel());
            unawaited(cancelaListeners());
            salimos = true;
            break;
          }
        }
        // Si llevo demasiado tiempo con uiPresent = true, la vuelvo a poner a false por si acaso...
        // Ojo, si la ui está presente, no compruebo las surveys. Espero a que el usuario cierre la app
        if (uiPresent) {
          milog.info("uiPresent = true -> no compruebo surveys");
          if (/*!ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS && */
              (currentTime.millisecondsSinceEpoch - lastTimeUiStartedPresent.millisecondsSinceEpoch >
                  MAX_SECONDS_SEGUIDOS_UI_PRESENT * 1000)) {
            uiPresent = false;
            // milog.shout("Pongo UiPresent = false a mano!!!");
            milog.info("Pongo UiPresent = false a mano!!!");
          }
        }
        //////////////////////  LIGHT //////////////////////
        if (USE_LIGHT && currentTime.millisecondsSinceEpoch - lastTimeLight > DELTA_LIGHT_MEASURE) {
          try {
            await measureLight(durationSeconds: LIGHT_SAMPLING_DURATION_SECONDS, code: code, deviceInfo: deviceInfo);
            lastTimeLight = currentTime.millisecondsSinceEpoch;
          } catch (e, s) {
            milog.shout("Error al hacer measureLight: ${e.toString()} ${s.toString()}");
          }
        }
        //////////////////////  NOISE_METER //////////////////////
        if (USE_NOISE_METER && currentTime.millisecondsSinceEpoch - lastTimeNoise > DELTA_NOISE_MEASURE) {
          try {
            await measureNoise(durationSeconds: NOISE_SAMPLING_DURATION_SECONDS, code: code, deviceInfo: deviceInfo);
            lastTimeNoise = currentTime.millisecondsSinceEpoch;
          } catch (e, s) {
            milog.shout("Error al hacer measureNoise: ${e.toString()} ${s.toString()}");
          }
        }
        ////////////////////////  SURVEYS //////////////////////
        if (surveys != null &&
            !uiPresent &&
            // conectado &&
            (currentTime.millisecondsSinceEpoch - lastTimeSurveyCheck > DELTA_SURVEY_CHECK)) {
          // Lo primero que tengo que ver es ver si desde la UI han contestado la última que había pendiente
          // cada cierto tiempo hay que hacer esto para actualizar los valores que me ha podido dar la UI
          try {
            if (prefs != null) {
              ultimoMensaje = "prefs.reload";
              await prefs.reload().timeout(timeoutValue);
            }
          } catch (e, s) {
            milog.shout("Error al hacer prefs.reload -> sigo p'alante sin esto!!! ${e.toString()} ${s.toString()}");
          }
          // MIRO SI SE HA CONTESTADO A LA QUE HABÍA PENDIENTE
          if (pendingSurvey && prefs != null) {
            // declárala "final" si quitas la parte de ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS
            var dateLastCompletedSurvey = prefs.getInt(SHARED_DATE_LAST_COMPLETED_SURVEY);
            if (dateLastCompletedSurvey != null &&
                (dateLastCompletedSurvey >
                    (ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS
                        ? dateStartLongTask.millisecondsSinceEpoch
                        : datePendingSurvey.millisecondsSinceEpoch))) {
              // ya se ha contestado
              milog.info("Esta survey ya se ha contestado");
              if (ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS) {
                // para movernos rápidamente en el tiempo hasta la siguiente
                desaceleraPeriodoBuclePrincipalPorPendingSurvey = false;
                prefs.remove(SHARED_DATE_LAST_COMPLETED_SURVEY);
                dateLastCompletedSurvey = currentTime.millisecondsSinceEpoch;
              }
              pendingSurvey = false;
              completedSurveys[hourPendingSurvey] = dateLastCompletedSurvey;
              try {
                final completedSurveysJson = jsonEncode(completedSurveys);
                await prefs.setString(SHARED_COMPLETED_SURVEYS, completedSurveysJson);
                // por si acaso le pusimos la notificación después de quitarla la UI xq todavía no había contestado, pero estaba en ello
              } catch (e, s) {
                milog.shout("Error al hacer jsonEncode o prefs.setString de completedSurveysJson: ${e.toString()} ${s.toString()}");
              }
              try {
                // por si acaso le pusimos la notificación después de quitarla la UI xq todavía no había contestado, pero estaba en ello
                await fsNotificationService.cancel(pendingSurveyID);
              } catch (e, s) {
                milog.info("Error al hacer fsNotificationService.cancel: ${e.toString()} ${s.toString()}");
              }
            }
          }
          // MIRO SI LA QUE HABÍA PENDIENTE HA CADUCADO (Esto hay que hacerlo después de mirar si se ha contestado la que había pendiente)
          if (prefs != null && pendingSurvey) {
            // si la UI está en uso mejor no miro esto ahora por si se está contestando ahora mismo
            final waitingTime = (pendingSurveyID == WEEKLY_SURVEY_ID)
                ? MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_WEEKLY
                : MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_DAILY;
            if (currentTime.difference(datePendingSurvey).inMinutes > waitingTime) {
              milog.info(
                  "Ya hemos esperado demasiado: esta survey no se ha contestado: ${currentTime.toIso8601String()} vs ${datePendingSurvey.toIso8601String()}");
              try {
                await prefs.remove(SHARED_SURVEY_ID).timeout(const Duration(seconds: 10));
                pendingSurvey = false;
                if (ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS) {
                  // para movernos rápidamente en el tiempo hasta la siguiente
                  desaceleraPeriodoBuclePrincipalPorPendingSurvey = false;
                }
                await fsNotificationService.cancel(pendingSurveyID);
              } catch (e, s) {
                milog
                    .shout("Error al hacer prefs.remove(SHARED_SURVEY_ID) o fsNotificationService.cancel: ${e.toString()} ${s.toString()}");
              }
            }
          }
          // Y AHORA MIRO SI HAY QUE NOTIFICAR UNA NUEVA ENCUESTA QUE SE DEBE CONTESTAR DESDE LA UI
          // Si está la UI presente, no envío ninguna notificación (espero a que esté cerrada). Es posible
          // que esté contestando a una encuesta. En cualquier caso, si está la UI presente, la
          // notificación no va a tener efecto
          for (var survey in surveys) {
            try {
              final int surveyId = survey['surveyId'];
              final String hours = survey['hours'].toString();
              final String weekdays = survey['weekdays'].toString();
              final List<String> listaWeekdays =
                  weekdays.replaceAll("[", "").replaceAll("]", "").replaceAll("}", "").replaceAll("{", "").split(",");
              if (prefs != null && listaWeekdays.contains(currentTime.weekday.toString())) {
                milog.info("Estamos dentro de un weekday de survey #$surveyId!!! ${currentTime.toString()} $listaWeekdays");
                final List<String> listaHoras =
                    hours.replaceAll("[", "").replaceAll("]", "").replaceAll("}", "").replaceAll("{", "").split(",");
                //////////////////
                for (final horaString in listaHoras) {
                  final hora = int.tryParse(horaString) ?? -1;
                  if (hora == -1) {
                    milog.shout("Ojo!!! Error al hacer tryParse $horaString");
                    continue;
                  }
                  final startTime = DateTime(currentTime.year, currentTime.month, currentTime.day, hora, 0, 0, 0);
                  final waitingTime = (surveyId == WEEKLY_SURVEY_ID)
                      ? MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_WEEKLY
                      : MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_DAILY;
                  if ((currentTime.millisecondsSinceEpoch >= startTime.millisecondsSinceEpoch + offsetMinutoSurvey * 60 * 1000) &&
                      (currentTime.millisecondsSinceEpoch <= startTime.millisecondsSinceEpoch + waitingTime * 60 * 1000)) {
                    milog.info(
                        "Ahora debería saltar una survey, si no se ha contestado ya #$surveyId!!! ${currentTime.toString()} $listaHoras $offsetMinutoSurvey");
                    final lastTimeTheSurveyOfThisHourWasCompleted = completedSurveys[hora];
                    // Para permitir que alguien conteste una weekly survey que se le haya pasado
                    // lo que voy a hacer es permitir que en el scheduling de surveys
                    // se pueda poner que la survey 4 (la weekly) survey se pueda poner en 2-3 días seguidos,
                    // de tal forma que si no se contestó un día, se pueda hacer al día siguiente
                    final deltaUltimaSurveyContestadaParaConsiderarYaCaducada = (surveyId == WEEKLY_SURVEY_ID)
                        ? deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysSemanales
                        : deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysHorarias;
                    if (currentTime.millisecondsSinceEpoch - lastTimeTheSurveyOfThisHourWasCompleted >
                        deltaUltimaSurveyContestadaParaConsiderarYaCaducada) {
                      milog.info("Ahora SÍ salta una survey #$surveyId!!! ${currentTime.toString()} $listaHoras $offsetMinutoSurvey");
                      // Aquí va el código para enviar la notificación
                      if (ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS) {
                        desaceleraPeriodoBuclePrincipalPorPendingSurvey = true;
                      }
                      ultimoMensaje = "notifications initialize";
                      final devuelve = await fsNotificationService.initialize(initializationSettings).timeout(timeoutValue);
                      //devuelve true -> no sé si debería comprobarlo
                      milog.info("HECTOR: fsNotificationService.initialize devuelve $devuelve");

                      if ((prefs.getInt(SHARED_SURVEY_ID) ?? -1) != surveyId) {
                        // si ya existía y valía surveyId, mejor no lo toco por si al volver a
                        // poner ese valor machaco un cambio que se esté produciendo ahora mismo
                        if (prefs.containsKey(SHARED_SURVEY_PENDING_TO_BE_SENT)) {
                          milog.info(
                              "SHARED_SURVEY_PENDING_TO_BE_SENT y no se ha enviado, pero ahora vamos a lanzar una nueva -> lo añado a la lista de data points y ya se enviará...");
                          final surveyToBeSent = prefs.getString(SHARED_SURVEY_PENDING_TO_BE_SENT) ?? "";
                          if (surveyToBeSent != "") {
                            listaDataPoints.add(surveyToBeSent);
                            try {
                              await prefs.remove(SHARED_SURVEY_PENDING_TO_BE_SENT).timeout(const Duration(seconds: 10));
                            } catch (e) {
                              milog.shout("Timeout al hacer prefs.remove SHARED_SURVEYS_PENDING_TO_BE_SENT");
                            }
                          }
                        }
                        ultimoMensaje = "SHARED_SURVEY_ID";
                        await prefs.setInt(SHARED_SURVEY_ID, surveyId).timeout(timeoutValue);
                      }
                      pendingSurveyID = surveyId;
                      // si ya estaba pendiente, no actualizo datePendingSurvey
                      if (!pendingSurvey) {
                        pendingSurvey = true;
                        hourPendingSurvey = hora;
                        if (COMENZAR_A_ESPERAR_PENDING_SURVEY_DESDE_LA_HORA_EN_PUNTO_Y_NO_DESDE_PRIMERA_NOTIFICACION) {
                          datePendingSurvey = startTime;
                        } else {
                          // Ten en cuenta que es posible que notifiquemos a las 17:05 la survey de las 16h si le hemos dado > 60 minutos para
                          // contestar y el móvil estaba en optimización de batería durante las 16h!!!!
                          datePendingSurvey = currentTime;
                        }
                      } else {
                        // quitamos la notificación anterior, si sigue ahí, para poner una nueva
                        // así le vibrará o le sonará al usuario (en el caso de que lo tenga configurado así)
                        try {
                          // por si acaso le pusimos la notificación después de quitarla la UI xq todavía no había contestado, pero estaba en ello
                          await fsNotificationService.cancel(pendingSurveyID);
                        } catch (e, s) {
                          milog.info("Error al hacer fsNotificationService.cancel: ${e.toString()} ${s.toString()}");
                        }
                      }
                      ultimoMensaje = "notifications show";
                      await fsNotificationService
                          .show(surveyId, Strings.appName, Strings.surveyNotificationText, platformChannelSpecifics, payload: 'item x')
                          .timeout(timeoutValue);
                    }
                  }
                }
              }
            } catch (e, s) {
              milog.shout("checkPendingSurveys: Ha habido una excepción... pero hay que seguir p'alante: ${e.toString()}, ${s.toString()}");
            }
          }
          lastTimeSurveyCheck = currentTime.millisecondsSinceEpoch;
        }
        ////////////////////////  UPDATE DOCUMENTS //////////////////////
        if (prefs != null &&
            conectado &&
            (currentTime.millisecondsSinceEpoch - lastTimeDocumentsDownloaded > DELTA_DOCUMENTS_DOWNLOAD) &&
            studyCredentials != null &&
            (await isServerResponding())) {
          try {
            //cada cierto tiempo leo esto por si el servidor cambian los contenidos de las encuestas 3 y 4
            // Voy a descargar todas las encuestas

            const documentsUri = "$serverUri/api/studies/null/documents/";
            ultimoMensaje = "CarpBackend initialize";
            if (CarpService().currentUser == null || (CarpService().currentUser?.token?.hasExpired ?? true)) {
              await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);
            }
            for (var i = 3; i <= 4; i++) {
              final docUri = "$documentsUri$i";
              final response = await httpr.get(docUri, headers: CarpService().headers, timeout: MI_TIMEOUT, delay: 2, maxAttempts: 2);
              int httpStatusCode = response.statusCode;
              if (httpStatusCode == HttpStatus.ok) {
                final docAlmacenado = prefs.getString("$SHARED_SURVEY_$i");
                if (docAlmacenado != response.body) {
                  ultimoMensaje = "SHARED_SURVEY_$i";
                  await prefs.setString("$SHARED_SURVEY_$i", response.body).timeout(timeoutValue);
                  milog.info("Encuesta $i actualizada");
                }
              }
              // si hay fallo, no hacemos nada
            }
            lastTimeDocumentsDownloaded = currentTime.millisecondsSinceEpoch;
          } catch (e, s) {
            milog.shout("Error al descargar documents (no es grave porque tenemos backup): ${e.toString()} ${s.toString()}");
          }
        }
        ////////////////////////  UPDATE SURVEYS SCHEDULE //////////////////////
        if (prefs != null &&
            conectado &&
            (currentTime.millisecondsSinceEpoch - lastTimeSurveysSchedulingDownloaded > DELTA_SURVEYS_SCHEDULING_DOWNLOAD) &&
            (await isServerResponding())) {
          try {
            //cada cierto tiempo leo esto por si el servidor cambia los momentos en los que hacer alguna encuesta
            ultimoMensaje = "getSurveysJsonFromAPIREST";
            surveysJson = await getSurveysJsonFromAPIREST(studyCode).timeout(timeoutValue);
            final previousSurveysScheduling = prefs.getString(SHARED_STUDY_SURVEYS);
            if (previousSurveysScheduling != surveysJson) {
              surveys = jsonDecode(surveysJson);
              ultimoMensaje = "SHARED_STUDY_SURVEYS";
              await prefs.setString(SHARED_STUDY_SURVEYS, surveysJson).timeout(timeoutValue);
              milog.info("Survey scheduling updated");
            }
            lastTimeSurveysSchedulingDownloaded = currentTime.millisecondsSinceEpoch;
          } catch (e, s) {
            milog.shout("Error al descargar temporización surveys (no es grave porque tenemos backup): ${e.toString()} ${s.toString()}");
          }
        }
        ////////////////////// CHECK salimos //////////////////////
        if (salimos) {
          milog.shout("Recibido! salimos del bucle!!!");
          if (pendingSurvey) {
            try {
              await fsNotificationService.cancel(pendingSurveyID);
            } catch (e, s) {
              milog.info("Error al hacer fsNotificationService.cancel: ${e.toString()} ${s.toString()}");
            }
          }
          break;
        }
        // De vez en cuando miro si hay conexión REAL a Internet aunque la conexión no haya cambiado
        // esto tb estaba hecho en el código de Carlos -> ponerlo aquí
      } catch (e) {
        final mensajeError = "HECTOR: ERROR EN EL BUCLE PRINCIPAL DE LA LONG TASK!!! LO IGNORO PERO OJO!!!:  ${e.toString()}\n";
        milog.shout(mensajeError);
      }
      //////////////  FIN DEL BUCLE ////////////////
      try {
        if (!ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS) {
          await Future.delayed(const Duration(seconds: NUM_SECONDS_MAIN_LOOP_LONG_TASK));
          currentTime = DateTime.now();
        } else {
          var retardo = 500;
          if (desaceleraPeriodoBuclePrincipalPorPendingSurvey) {
            retardo = 2000;
          }
          await Future.delayed(Duration(milliseconds: retardo));
          currentTime = currentTime.add(const Duration(minutes: 1));
        }
        // EN CADA ITERACIÓN DEL BUCLE PRINCIPAL ACTUALIZAMOS EL WATCH DOG DE LAS NOTIFICACIONES (ESTO ES MUY IMPORTANTE: si la app arranca y el proceso estaba frozen, esperando unos segundos nos llegará el update del watchdog)
        // A parte, así en las notificaciones nos saldrá que está la app ok con mucha más frecuencia (y esto no repercute en la batería del móvil: si el usuario no mira la notificación, el S.O. ni se preocupa)
        // lo pongo aquí para que sea lo primero que haga tras el Future.delayed (por si el S.O. congela el proceso, lo normal es que sea aquí)
        final watchDogTime = currentTime.toIso8601String();
        appServiceData.watchdog = watchDogTime;
        if (MOSTRAR_INFO) {
          appServiceData.mensaje =
              "App Ok: [${currentTime.hour}:${currentTime.minute}. Día:${currentTime.weekday}], CONN=$conectado, UI=$uiPresent";
        } else {
          appServiceData.mensaje = Strings.appOk;
        }
        // Ya update mira desde el servicio si la UI está presente. Si no lo está, no lo envía -> no necesito mirarlo aquí
        ultimoMensaje = "ServiceClient.update9";
        await ServiceClient.update(appServiceData).timeout(timeoutValue);
        milog.info("${appServiceData.mensaje}, It: $numItLongTask");
      } catch (e) {
        final mensajeError =
            "HECTOR: ERROR AL FINAL DEL TODO DEL BUCLE PRINCIPAL DE LA LONG TASK!!! LO IGNORO PERO OJO!!!: ultimoMensaje = $ultimoMensaje, e=${e.toString()}\n";
        milog.shout(mensajeError);
      }
    }
  }

  ServiceClient.setExecutionCallback(myDartCode, myEndDartCode, myUiPresentCode, myUiNotPresentCode);
}

// Future<void> checkPendingSurveys({List<dynamic> surveys}) async {
//   milog.info("En checkPendingSurveys");
//
//   if (surveys != null) {
//     DateTime now = DateTime.now();
//     surveys.forEach(
//       (survey) {
//         try {
//           final int surveyId = survey['surveyId'];
//           final String hours = survey['hours'].toString();
//           final String weekdays = survey['weekdays'].toString();
//           final List<String> listaWeekdays =
//               weekdays.replaceAll("[", "").replaceAll("]", "").replaceAll("}", "").replaceAll("{", "").split(",");
//           if (listaWeekdays.contains(now.weekday.toString())) {
//             milog.info(
//                 "Estamos dentro de un weekday de survey #$surveyId!!! ${now.toString()} $listaWeekdays");
//             final List<String> listaHoras =
//                 hours.replaceAll("[", "").replaceAll("]", "").replaceAll("}", "").replaceAll("{", "").split(",");
//             if (listaHoras.contains(now.hour.toString())) {
//               milog.info(
//                   "Estamos dentro de una hora de survey #$surveyId!!! ${now.toString()} $listaHoras");
//             }
//           }
//         } catch (e) {
//           milog.shout(
//               "checkPendingSurveys: Ha habido una excepción... pero hay que seguir p'alante: $e");
//         }
//       },
//     );
//   }
// }

// antiguo bucle para ver si hay que notificar encuestas
//////////////////
/*
                  if (listaHoras.contains(currentTime.hour.toString())) {
                    milog.info(
                        "Estamos dentro de una hora de survey #$surveyId!!! ${currentTime.toString()} $listaHoras");
                    // Hay un número aleatorio de minutos (entre 0 y 5) para evitar que todos contesten a la vez
                    if ((currentTime.minute >= offsetMinutoSurvey) &&
                        (currentTime.minute <=
                            offsetMinutoSurvey +
                                MAX_MINUTOS_ESPERANDO_PENDING_SURVEY)) {
                      // Estamos en la hora de la encuesta y el minuto está en el rango en el que se debe contestar
                      // P.ej. si offsetMinutoSurvey = 0, nos vale entre las xx:00 y las xx:50
                      // Ahora hay que mirar que esa survey no haya sido ya contestada
                      milog.info(
                          "Ahora debería saltar una survey, si no se ha contestado ya #$surveyId!!! ${currentTime.toString()} $listaHoras $offsetMinutoSurvey");
                      final lastTimeTheSurveyOfThisHourWasCompleted =
                          completedSurveys[currentTime.hour];
                      // Para permitir que alguien conteste una weekly survey que se le haya pasado
                      // lo que voy a hacer es permitir que en el scheduling de surveys
                      // se pueda poner que la survey 4 (la weekly) survey se pueda poner en 2-3 días seguidos,
                      // de tal forma que si no se contestó un día, se pueda hacer al día siguiente
                      final deltaUltimaSurveyContestadaParaConsiderarYaCaducada =
                          (surveyId == 4)
                              ? deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysSemanales
                              : deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysHorarias;
                      // Para surveys tipo 3 y, en general, si han pasado más de 2 horas desde que se contestó la encuesta de las xxx horas
                      // Obviamente, si fue ayer habrán pasado muchas más y si ha sido hoy habrán
                      // pasado como mucho 60 minutos -> con 2 horas es suficiente para distinguir los dos casos
                      // Para surveys tipo 4 (weekly survey), si han pasado más de 5 días de la última vez que se contestó
                      // permitimos que salga de nuevo:
                      if (currentTime.millisecondsSinceEpoch -
                              lastTimeTheSurveyOfThisHourWasCompleted >
                          deltaUltimaSurveyContestadaParaConsiderarYaCaducada) {
                        milog.info(
                            "Ahora SÍ salta una survey #$surveyId!!! ${currentTime.toString()} $listaHoras $offsetMinutoSurvey");
                        // Aquí va el código para enviar la notificación
                        if (ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS) {
                          desaceleraPeriodoBuclePrincipalPorPendingSurvey =
                              true;
                        }
                        final devuelve = await fsNotificationService
                            .initialize(initializationSettings)
                            .timeout(timeoutValue);
                        //devuelve true -> no sé si debería comprobarlo
                        milog.info(
                            "HECTOR: fsNotificationService.initialize devuelve $devuelve");

                        if ((prefs.getInt(SHARED_SURVEY_ID) ?? -1) !=
                            surveyId) {
                          // si ya existía y valía surveyId, mejor no lo toco por si al volver a
                          // poner ese valor machaco un cambio que se esté produciendo ahora mismo
                          await prefs
                              .setInt(SHARED_SURVEY_ID, surveyId)
                              .timeout(timeoutValue);
                        }
                        pendingSurveyID = surveyId;
                        if (!pendingSurvey) {
                          pendingSurvey = true;
                          datePendingSurvey = currentTime;
                        } else {
                          // quitamos la notificación anterior, si sigue ahí, para poner una nueva
                          // así le vibrará o le sonará al usuario (en el caso de que lo tenga configurado así)
                          try {
                            // por si acaso le pusimos la notificación después de quitarla la UI xq todavía no había contestado, pero estaba en ello
                            await fsNotificationService.cancel(pendingSurveyID);
                          } catch (e, s) {
                            milog.info(
                                "Error al hacer fsNotificationService.cancel: ${e.toString()} ${s.toString()}");
                          }
                        }
                        // si ya estaba pendiente, no actualizo datePendingSurvey
                        await fsNotificationService
                            .show(
                                surveyId,
                                Strings.appName,
                                Strings.surveyNotificationText,
                                platformChannelSpecifics,
                                payload: 'item x')
                            .timeout(timeoutValue);
                      }
                    }
                  }
                  */
