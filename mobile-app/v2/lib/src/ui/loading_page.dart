import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';

import 'package:android_long_task/long_task/app_client.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/models/permission_request_result.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:research_package/research_package.dart';
import 'package:uuid/uuid.dart';
// DEFAULT SURVEYS AND SCHEDULING
import '../default/study2/informed_consent_study2.dart';
import '../default/study2/daily_survey_study2.dart';
import '../default/study2/initial_survey_study2.dart';
import '../default/study2/weekly_survey_study2.dart';
import '../default/study2/study_surveys_default.dart';

import '../../credentials.dart';
import '../../long_task_functions.dart';
import '../../main.dart';
import '../../my_logger.dart';
import '../exceptions.dart';
import '../helper_functions.dart';
import '../strings.dart';
import '../carp_backend/carp_backend_modificado.dart';
import 'service_not_available_page.dart';
import 'survey_page.dart';
import 'login_page.dart';
import 'main_page.dart';

class LoadingPage extends StatefulWidget {
  final String? code;
  final String? loadingText;

  const LoadingPage({Key? key, this.code, this.loadingText}) : super(key: key);

  @override
  LoadingPageState createState() => LoadingPageState();
}

/// This page will be called 4 times:
/// 1 - Display login page
/// 2 - Present the informed consent (only backend initialized)
/// 3 - Present the initial survey
/// 4 - Show main screen (foreground service initialized)

class LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  // Para que se ejecute un async solo la primera vez. Una forma es meterlo en initState
  // usando un then() pero prefiero usarlo con didChangeDependencies usando esta variable (me resulta más fácil de entender)
  bool firstTime = true;
  bool checkBackgroundServiceOkLocked = false; // para evitar re-entradas
  // Workflow flags
  bool consentUploaded = false;
  bool initialSurveyUploaded = false;
  bool deviceIdUploaded = false;
  bool pendingSurvey = false;
  bool requestAgain = false;
  bool serviceNotAvailable = false;
  late Future<bool> _miLogin;

  // Survey tasks
  RPOrderedTask? consentTask;
  RPOrderedTask? initialSurveyTask;
  RPOrderedTask? surveyTask;

  // Other objects

  // Stream<ActivityEvent> activityStream;
  StreamSubscription<Map<String, dynamic>?>? miLongTaskStreamSubscription;

  /// App lifecycle state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      await AppClient.sendAppPaused();
      // if (finalizeApp) {
      //   SystemNavigator.pop();
      // }
    }
    if (state == AppLifecycleState.resumed) {
      await AppClient.sendAppResumed();
    }
    if (state == AppLifecycleState.detached) {
      miLongTaskStreamSubscription?.cancel();
      miLongTaskStreamSubscription = null;
    }
  }

  /// Executed before the loading page is displayed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Vamos buscando la variable _miLogin mientras inicializamos el resto de variables
    // fíjate que login devuelve un future -> perfecto para ser usado en FutureBuilder más adelante
    _miLogin = login(widget.code ?? "");
    miLongTaskStreamSubscription = getLongTaskStreamSubscription();
    initializeNotifications();
    firstTime = true;
    ResearchPackage.ensureInitialized();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (firstTime) {
      await startService(null); // si ya se está ejecutando, no pasa nada
      await AppClient.sendAppResumed();
    }
    firstTime = false;
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // pongo esto al final porque me da un error
    await AppClient.sendAppPaused();
  }

  Future<void> sendKillSignalOldLongTasks(String newUuid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // todas las anteriores, pasan a la lista de uuid que hay que matar
      final uuidToBeKilled = prefs.getStringList(SHARED_LT_UUID_LIST) ?? [];
      if (uuidToBeKilled.contains(newUuid)) {
        milog.shout("Fallo en sendKillSignalOldLongTasks: la uuid $newUuid ya existía!!! No vamos a matar la recién creada long task");
        return;
      }
      final updatedUuidList = [newUuid, ...uuidToBeKilled];
      await prefs.setStringList(SHARED_LT_UUID_LIST, updatedUuidList).timeout(const Duration(seconds: 5));
      await prefs.setStringList(SHARED_LT_UUID_LIST_TO_BE_KILLED, uuidToBeKilled).timeout(const Duration(seconds: 5));
    } catch (e) {
      milog.shout("Fallo en sendKillSignalOldLongTasks: seguimos sin usar esta característica");
    }
  }

  /// Initialization functions
  Future<void> initLongTask() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    debugPrint("Ejecuto prepareLongTask");
    appServiceData.uuid = const Uuid().v4();
    await sendKillSignalOldLongTasks(appServiceData.uuid);
    await prepareLongTask(appServiceData);
    await Future.delayed(const Duration(milliseconds: 2000));
    debugPrint("Ejecuto runLongTask");
    await runLongTask();
    await Future.delayed(const Duration(milliseconds: 5000));
  }

  // WATCH DOG
  Future<DateTime?> getLogDataWatchDog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Debo hacer reload ya que el dato se ha cambiado desde otra parte de la app (aunque parece que no es necesario)
      await prefs.reload();
      String logData = "";
      if (prefs.containsKey(LOG_WATCH_DOG)) {
        logData = prefs.getString(LOG_WATCH_DOG) ?? "";
      }
      if (logData != "" && logData.isNotEmpty) {
        return DateTime.tryParse(logData);
      }
      return null;
    } catch (e) {
      final mensaje = "HECTOR: getLogDataWatchDog da una excepción: $e";
      debugPrint(mensaje);
      return null;
    }
  }

  Future<bool> isBackgroundTaskRunningViaWatchDog(int numMaxSeconds) async {
    try {
      DateTime? ultimaFecha;
      // Esta primera parte la comento: es solo por si quieres buscar exactamente por uuid (ten en cuenta que lo normal es que no sepamos
      // la uuid porque no hayamos creado la long_task desde esta UI concreta)
      // String? tmp;
      // // Primero miro en lo que ya he recibido desde que comenzó la UI
      // final uuid = appServiceData.uuid;
      // if (uuid.isNotEmpty) tmp = lastWatchDogReceivedByUuid[uuid];
      // // Si no obtenemos respuesta, busco la de cualquier uuid
      // if (tmp == null || tmp.isEmpty) {
      //   tmp = lastWatchDogReceivedByUuid['any'];
      // }

      // Esto es importante porque al comprobar si hay servicio, vamos a enviar un appServiceData con watchdog = '' y lo podemos confundir
      // con el que recibimos de la long_task
      String? tmp = lastWatchDogReceivedByUuid['any'];
      // Si eso no basta, pregunto al servicio por el último mensaje, ignorando el uuid
      if (tmp == null || tmp.isEmpty) {
        final json = await getDataMessage();
        if (json != null) {
          tmp = json['watchdog'];
        }
      }
      if (tmp != null && tmp.isNotEmpty) ultimaFecha = DateTime.tryParse(tmp);
      // ultimaFecha ??= await getLogDataWatchDog();
      if (ultimaFecha != null) {
        debugPrint("HECTOR: isBackgroundTaskRunningViaWatchDog,  ultimaFecha obtenida de json['watchdog']=$ultimaFecha");
      } else {
        ultimaFecha = await getLogDataWatchDog();
        debugPrint("HECTOR: isBackgroundTaskRunningViaWatchDog,  ultimaFecha obtenida de getLogDataWatchDog=$ultimaFecha");
      }

      if (ultimaFecha == null) return false;
      final numSeconds = DateTime.now().difference(ultimaFecha).inSeconds;
      if (numSeconds > numMaxSeconds) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialization functions
  Future<void> initLongTaskIfNotRunning() async {
    if (!await isServiceClientListening()) {
      // no hay background task al otro lado: lo arrancamos tot, pero por si acaso volvemos a comprobarlo (alguna vez me ha pasado que la app estaba congelada, esto ha devuelto que no hay y sì que habìa un proceso)
      await Future.delayed(const Duration(seconds: 2));
      if (!await isServiceClientListening()) {
        await initLongTask();
        return;
      }
    }
    // aquí ya tenemos servicio y hay algo al otro lado, pero no sabemos
    // si el bucle sigue activo. Compruebo el "watch dog"
    if (!await isBackgroundTaskRunningViaWatchDog(MAX_SECONDS_WATCH_DOG_LONG_TASK_CONSIDERED_CRASHED)) {
      // Esta es una situación EXCEPCIONAL. Por si acaso, esperamos unos segundos y volvemos a intentarlo.
      // Es posible que el proceso estuviera congelado por el S.O. y el usuario ejecutara la notificación de la app
      // y no haya dado tiempo a que el proceso pudiera enviar un nuevo watchdog.
      await Future.delayed(const Duration(seconds: 5 + NUM_SECONDS_MAIN_LOOP_LONG_TASK));
      if (!await isBackgroundTaskRunningViaWatchDog(MAX_SECONDS_WATCH_DOG_LONG_TASK_CONSIDERED_CRASHED)) {
        // lo paramos tot (menos el servicio) y lo re-ejecutamos
        //en prepareLongTask se arranca de nuevo el servicio
        const mensaje = "HECTOR: REINICIAMOS EL SERVICIO Y LA LONG TASK!!!";
        debugPrint(mensaje);
        sendLogToServer(mensaje);

        await stopLongTask(stopServiceToo: true);
        // En programas donde solo puede haber una, es preferible poner stopServiceToo = true ya que te garantiza que el
        // proceso en background va a terminar sí o sí (o lo hace por las buenas o por las malas).
        // MEJOR NO: pongo stopServiceToo = false porque ya hay servicio -> más rápido
        // 20s tenía en la otra app (help...), pero he visto que no hace falta esperar, la tarea recibe el salimos y ya saldrá cuando llegue
        // ahí (si es que todavía sigue). El nuevo "salimos" no le afecta a la que se inicia a continuación.
        await Future.delayed(const Duration(seconds: 10));
        await initLongTask();
      }
    }
  }

  // Initialize notifications
  void initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin?.initialize(initializationSettings);
  }

  // Future<void> initStudy({Map studyCredentials}) async {
  //   if (studyCredentials != null) {
  //     await bloc.initialize();
  //     await CarpBackend().initialize(credentials: studyCredentials);
  //     await Sensing().initialize(credentials: studyCredentials);
  //   }
  // }

  Future<void> initializeAll() async {
    // await initStudy(studyCredentials: studyCredentials);
    // await initActivityTracking();
    if (RUN_LONG_TASK) {
      await initLongTaskIfNotRunning();
      // finalizeApp = true;
    }
  }

  Future<bool> checkAndRequestNotificationsPermissions() async {
    if (Platform.isAndroid) {
      bool? granted = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      if (!granted) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        granted = await androidImplementation?.requestPermission();
      }
      if (granted == true) return true;
    }
    return false;
  }

  Future<void> askForPermissions() async {
    //////////
    var sdkVersion = -1;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      sdkVersion = info.version.sdkInt;
    } catch (e) {
      debugPrint("Error al obtener sdkVersion. No es importante: ${e.toString()}");
    }
    if (sdkVersion > 28) {
      // 28 y anteriores no necesitan esto para poder iniciarse en reboot
      try {
        if (!await Permission.systemAlertWindow.isGranted) {
          await Permission.systemAlertWindow.request();
        }
      } catch (e) {
        milog.shout("Fallo al pedir systemAlertWindow permission");
      }
    }

    try {
      if (await Permission.activityRecognition.request().isGranted) {
        debugPrint("Permission.activityRecognition.request().isGranted");
      }
      // copio-pego del ejemplo de flutter_activity_recognition (supongo que esto es innecesario)
      PermissionRequestResult reqResult;
      reqResult = await activityRecognition.checkPermission();
      if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
        milog.shout('Permission is permanently denied.');
        throw Exception("No tenemos permisos de reconocimiento de actividad!");
      } else if (reqResult == PermissionRequestResult.DENIED) {
        reqResult = await activityRecognition.requestPermission();
        if (reqResult != PermissionRequestResult.GRANTED) {
          milog.shout('Permission is denied.');
          throw Exception("No tenemos permisos de reconocimiento de actividad!");
        }
      }
      // if (sdkVersion <= 28 && !await Permission.storage.isGranted) {
      //   // Mira en https://developer.android.com/reference/android/Manifest.permission
      //   //READ_EXTERNA_STORAGE
      //   // Starting in API level 29, apps don't need to request this permission to
      //   // access files in their app-specific directory on external storage
      //   await Permission.storage.request();
      // }
      // Parece que audio_streamer sí necesita esto (en general) -> lo pido
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      milog.shout("Exception in askForPermissions: activityRecognition or storage");
    }
    try {
      // al menos, nos conformamos con ésta si no está la otra
      if (!await Permission.location.isGranted) {
        await Permission.location.request();
      }
      if (!await Permission.locationAlways.isGranted) {
        await Permission.locationAlways.request();
      }
    } catch (e) {
      milog.shout("Exception in askForPermissions: location");
    }

    if (USE_NOISE_METER) {
      try {
        if (!await Permission.microphone.isGranted) {
          await Permission.microphone.request();
        }
      } catch (e) {
        milog.shout("Exception in askForPermissions: microphone");
      }
      try {
        if (!await Permission.manageExternalStorage.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      } catch (e) {
        milog.shout("Exception in askForPermissions: manageExternalStorage");
      }
    }
    // try {
    // En la API 33 hace falta también permiso para las notificaciones
    // no pongo ultimoMensaje porque lo envuelvo en try-catch (da igual que falle)
    // Pero creo que hace falta una versión más avanzada del paquete de Permission
    // porque no me sale ningún cuadro de diálogo en la API 33
    // YA TENGO UNA VERSIÓN MÁS AVANZADA -> LO PONGO
    try {
      if (!await Permission.notification.isGranted) {
        await Permission.notification.request();
      }
      // Este es equivalente al anterior
      // await checkAndRequestNotificationsPermissions();
    } catch (e) {
      milog.shout("Exception in askForPermissions: notification");
    }
    try {
      // Request ignore battery optimizations if necessary
      if (!await Permission.ignoreBatteryOptimizations.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      milog.shout("Exception in askForPermissions: ignoreBatteryOptimization");
    }

    //   bool permissionNotificationDenied =
    //       await Permission.notification.isDenied;
    //   if (permissionNotificationDenied == true) {
    //     await showDialog(
    //       // No hace falta el context. Parece que usa un get y lo coge bien?
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: Text(Strings.notificationsNotGranted),
    //           content: Text(Strings.notificationsNotGrantedText),
    //           actions: [
    //             TextButton(
    //                 child: Text("OK"),
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 })
    //           ],
    //         );
    //       },
    //     );
    //     Permission.notification.request();
    //   }
    // } catch (e) {
    //   milog.shout("Exception in askForPermissions: Notification");
    // }
  }

  // Show error dialogs
  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.error),
          content: Text(text),
          actions: [
            TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  // // Mark completed survey in database
  // HECTOR: YA NO NECESITAMOS ESTA FUNCIÓN
  // Future<void> markSurveyAsCompleted(int surveyID) async {
  //   final code = Settings().preferences.getString(SHARED_CODE);
  //   final uri = Uri.parse(apiRestUri + "/register_completed_survey");
  //   Map<String, dynamic> payload = {"code": code, "survey_id": surveyID};
  //   final response = await http.post(uri,
  //       body: jsonEncode(payload),
  //       headers: {"Content-Type": "application/json"});
  //   if (response.statusCode == 500 || response.statusCode == 503) {
  //     throw new ServerException();
  //   }
  // }

//   Future<void> pruebaAccesoServidorDirecto(String code) async {
//     // if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
//     //   // chequeamos si tenemos acceso al servidor
//     //   if (await isHostReachable() && await isServerResponding()) {
//     // Tenemos acceso al servidor
//     final studyCredentials = await getStudyFromAPIREST(code).timeout(timeoutValue);
//     await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);
//
//     DataPoint data = DataPoint.fromData(
//         Data(format: const DataFormat("es.ugr.ad-hoc", "ad-hoc data"), id: const Uuid().v4(), data: "Activity: STOLL; Confidence: 100"))
//       ..carpHeader.studyId = code.substring(5, 10)
//       ..carpHeader.userId = code.substring(0, 4)
//       ..carpHeader.dataFormat = DataFormat.fromString("ugr.adhoc")
//       ..carpHeader.deviceRoleName = "masterphone with USER_CODE = $code. Local Time = ${DateTime.now().toLocal().toIso8601String()}";
//     // debería verificar primero si el token no ha expirado...
//     const dataEndpointUri = "$serverUri/api/deployments/null/data-points";
//     final response = await httpr.post(Uri.encodeFull(dataEndpointUri),
//         headers: CarpService().headers, body: json.encode(data), maxAttempts: 3, delay: 2, timeout: MI_TIMEOUT);
//     int httpStatusCode = response.statusCode;
//     Map<String, dynamic> responseJson = json.decode(response.body);
//     if ((httpStatusCode == HttpStatus.ok) || (httpStatusCode == HttpStatus.created)) {
//       debugPrint("Post realizado con éxito. ID del nuevo elemento insertado: ${responseJson["id"]}");
//     } else {
//       // All other cases are treated as an error.
//       throw CarpServiceException(
//         httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
//         // message: responseJson["message"],
//         // path: responseJson["path"],
//       );
//     }
//
//     // Y ahora en modo batch:
//     const contenido3 = r'''[
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:54:14.668427Z","data_format":{"namespace":"dk.cachet.carp","name":"connectivity"}},"carp_body":{"id":"39ca2f90-e9a9-11ed-9c9f-5dad00593d58","connectivity_status":"wifi"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:01.338478Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"559beba0-e9a9-11ed-86cb-f9d046f1e4d3","screen_event":"SCREEN_OFF"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:01.379216Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"55a20620-e9a9-11ed-9317-ad03e8f4160d","screen_event":"SCREEN_UNLOCKED"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:01.509647Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"55b60350-e9a9-11ed-b4d2-bdc8cbfda559","screen_event":"SCREEN_ON"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:02.633740Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"56618590-e9a9-11ed-be7d-0f01fe6acacc","screen_event":"SCREEN_UNLOCKED"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:02.738254Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"56716410-e9a9-11ed-aec8-af77053d97df","screen_event":"SCREEN_OFF"}}
// ,
// {"carp_header":{"study_id":"NONE","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:02.816928Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"567d7200-e9a9-11ed-9bce-898c25055d8f","screen_event":"SCREEN_ON"}}
// ,
// {"carp_header":{"study_id":"cadena_de_caracteres_secundaria","device_role_name":"masterphone","trigger_id":"0","user_id":"Manolito","start_time":"2023-05-03T11:55:07.986993Z","data_format":{"namespace":"dk.cachet.carp","name":"screen"}},"carp_body":{"id":"59925320-e9a9-11ed-b34c-eb540a0dc4b1","screen_event":"SCREEN_OFF"}}
// ,
// {}
// ]
// ''';
//     // final hayError = utf8.encode(contenido3);
//     // print(hayError);
//     const dataEndpointBatchUri = "$serverUri/api/deployments/null/data-points/batch";
//
//     final success = await httpr.batchPostDataLongString(contenido3, dataEndpointBatchUri, CarpService().headers,
//         maxAttempts: 3, delay: 5, timeoutSeconds: MI_TIMEOUT);
//     if (success) {
//       debugPrint("SI LLEGAMOS AQUÍ -> YA ESTÁ ENVIADO: PODEMOS BORRAR ESOS DATOS PORQUE HAN LLEGADO AL SERVIDOR:");
//     }
//
//     debugPrint("Aquí ya debería haber terminado todo");
//     // Voy a descargar todas las encuestas
//     const documentsUri = "$serverUri/api/studies/null/documents/";
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     for (var i = 1; i <= 4; i++) {
//       final docUri = "$documentsUri$i";
//       final response = await httpr.get(docUri, headers: CarpService().headers, timeout: MI_TIMEOUT, delay: 2, maxAttempts: 3);
//       int httpStatusCode = response.statusCode;
//       if (httpStatusCode == HttpStatus.ok) {
//         await prefs.setString("$SHARED_SURVEY_$i", response.body).timeout(timeoutValue);
//       } else {
//         // Map<String, dynamic> responseJson = json.decode(response.body);
//         // All other cases are treated as an error.
//         throw CarpServiceException(
//           httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
//           // message: responseJson["message"],
//           // path: responseJson["path"],
//         );
//       }
//     }
//     //   }
//     // }
//   }

  Future<bool> login(String code) async {
    // milog.info("No dejo entrar en login. Devuelvo false");
    // return false;
    milog.info("Entrando en login");
    // if (code.length==10) {
    //   for (int i = 1; i <= 1; i++) {
    //     await pruebaAccesoServidorDirecto(code);
    //     await Future.delayed(const Duration(seconds: 5));
    //   }
    // }
    // Por si hay una excepción, saber por dónde íbamos (lo actualizo antes de cada await)
    var ultimoMensaje = "";
    try {
      // [1] If the code has not been received, redirect to login page
      if (code.isEmpty || code.length < 10) {
        requestAgain = true;
        milog.info("Saliendo de login");
        return true;
      }
      if (code.length > 10) {
        // a lo mejor ha puesto espacios de más, me quedo con los 10 primeros caracteres
        code = code.substring(0, 10);
      }
      final studyCode = code.substring(5, 10);

      // Check if consent and initial survey have been uploaded
      ultimoMensaje = "prefs";
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        milog.shout("UFF, fallo al hacer await SharedPreferences.getInstance()!!! Viejos fantasmas!!!");
      }

      if (INYECTAR_SURVEY) {
        ultimoMensaje = "prefs.setInt(SHARED_SURVEY_ID, SURVEY_INYECTADA)";
        await prefs?.setInt(SHARED_SURVEY_ID, SURVEY_INYECTADA);
      }
      consentUploaded = prefs?.containsKey("isConsentUploaded") ?? false;
      initialSurveyUploaded = prefs?.containsKey("isInitialSurveyUploaded") ?? false;
      if (consentUploaded && SALTARSE_INITIAL_SURVEY) {
        initialSurveyUploaded = true;
      }
      // Las dos anteriores solo se usan aquí -> da igual poner el string literal, pero la que viene sí se usa desde otras funciones -> uso constantes de main.dart
      deviceIdUploaded = prefs?.containsKey(SHARED_IS_DEVICE_ID_UPLOADED) ?? false;
      pendingSurvey = prefs?.containsKey(SHARED_SURVEY_ID) ?? false;
      // ResearchPackage.ensureInitialized();

      // [2] If the code has been received but no survey has been
      //     filled, just load backend and present informed consent
      if (!consentUploaded & !initialSurveyUploaded) {
        // Initialize backend
        // Si hemos llegado aquí es porque hay red -> este es el momento de aprovechar!!!!
        ultimoMensaje = "CarpBackend().initialize";
        final studyCredentials = await getStudyFromAPIREST(code).timeout(timeoutValue);
        await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);
        // Get informed consent task -> mejor descargo todas las encuestas (tarda más pero no creo que sea demasiado)
        ultimoMensaje = "Descargo todas las encuestas y las guardo en shared prefs";
        // Voy a descargar todas las encuestas
        const documentsUri = "$serverUri/api/studies/null/documents/";
        //final SharedPreferences prefs = await SharedPreferences.getInstance();
        for (var i = 1; i <= MAX_SURVEY_ID_TO_DOWNLOAD_AT_START; i++) {
          final docUri = "$documentsUri$i";
          final response = await httpr.get(docUri, headers: CarpService().headers, timeout: MI_TIMEOUT, delay: 2, maxAttempts: 3);
          int httpStatusCode = response.statusCode;
          if (httpStatusCode == HttpStatus.ok) {
            await prefs?.setString("$SHARED_SURVEY_$i", response.body).timeout(timeoutValue);
          } else {
            // Map<String, dynamic> responseJson = json.decode(response.body);
            // All other cases are treated as an error.
            throw CarpServiceException(
              httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
              // message: responseJson["message"],
              // path: responseJson["path"],
            );
          }
        }
        ultimoMensaje = "convierto la survey 1 a RPOrderedTask";
        final consentSurvey = prefs?.getString("${SHARED_SURVEY_}1") ?? "";
        // Si hay cualquier problema, uso el consentTask que tengo almacenado localmente -> con dejar consentTask = null
        // ya se cargará más abajo por defecto el que tenemos guardado en la app
        if (consentSurvey != "") {
          try {
            final consentSurveyMap = jsonDecode(consentSurvey);
            consentTask = RPOrderedTask.fromJson(consentSurveyMap['data'] as Map<String, dynamic>);
          } catch (e) {
            consentTask = null;
            milog.shout("consentTask = RPOrderedTask.fromJson da un error. Lo pongo a null y saco la que tenemos en la app");
          }
        } else {
          consentTask = null;
          milog.shout("consentSurvey == "
              ". Lo pongo a null y saco la que tenemos en la app");
        }

        // Si llegamos aquí, all ha ido bien -> Store user code in shared prefs
        ultimoMensaje = "prefs?.setString(SHARED_CODE)";
        await prefs?.setString(SHARED_CODE, code).timeout(timeoutValue);
        if (!deviceIdUploaded) {
          ultimoMensaje = "storeUser";
          // pongo checkConnection: false porque para llegar aquí tenemos internet seguro (a partir de mostrar el consentimiento, ya si que es posible que no)
          deviceIdUploaded = await storeUser(code, checkConnection: false).timeout(timeoutValue);
        }
        // Y finalmente, aprovechamos para guardar la temporización de las encuestas, así cuando arranque la long_task
        // ya dará igual si no tenemos conexión puntualmente. Si falla la cosa, ponemos la que tenemos por defecto
        String studySurveysJson = defaultStudySurveysJson;
        try {
          studySurveysJson = await getSurveysJsonFromAPIREST(studyCode).timeout(timeoutValue);
        } catch (e) {
          milog.shout("Falla getSurveysJsonFromAPIREST en loading_page: usamos los valores por defecto: e=${e.toString()}");
        }
        await prefs?.setString(SHARED_STUDY_SURVEYS, studySurveysJson).timeout(timeoutValue);

        // [3] If the code has been received and the informed consent has been
        // sent, but the initial survey not, just present initial survey
      } else if (consentUploaded & !initialSurveyUploaded) {
        ultimoMensaje = "askForPermissions 1";
        await askForPermissions();
        // await askForPermissions(); //lo pedimos dos veces por si se ha dejado alguno...

        if (!deviceIdUploaded) {
          ultimoMensaje = "storeUser";
          deviceIdUploaded = await storeUser(code, checkConnection: true).timeout(timeoutValue);
        }

        // Get initial survey task
        ultimoMensaje = "initialSurvey";
        final initialSurvey = prefs?.getString("${SHARED_SURVEY_}2") ?? "";
        // Si hay cualquier problema, uso el consentTask que tengo almacenado localmente -> con dejar consentTask = null
        // ya se cargará más abajo por defecto el que tenemos guardado en la app
        if (initialSurvey != "") {
          try {
            final initialSurveyMap = jsonDecode(initialSurvey);
            initialSurveyTask = RPOrderedTask.fromJson(initialSurveyMap['data'] as Map<String, dynamic>);
          } catch (e) {
            initialSurveyTask = null;
            milog.shout("initialSurveyTask = RPOrderedTask.fromJson da un error. Lo pongo a null y saco la que tenemos en la app");
          }
        } else {
          initialSurveyTask = null;
          milog.shout("initialSurvey == "
              ". Lo pongo a null y saco la que tenemos en la app");
        }
        // Creo que este es el momento ideal para generar, aunque sea 0s, la notificación
        // de survey_channel. Así, una vez ejecutada la app, cuando el usuario pulse
        // en las notificaciones, ya le saldrá el "survey_channel" y podrá configurarlo
        // para que suene o vibre o lo que quiera. Si no hacemos esto, tiene que esperar
        // a la primera encuesta que envíe la long_task
        try {
          AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails('surveyChannelID', 'surveyChannel',
              channelDescription: 'Survey Channel',
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showWhen: false,
              visibility: NotificationVisibility.public);

          final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
          const initialSurveyId = 2;
          await flutterLocalNotificationsPlugin
              ?.show(initialSurveyId, Strings.appName, Strings.surveyNotificationText, platformChannelSpecifics, payload: 'item x')
              .timeout(timeoutValue);
          // inmediatamente la cancelo -> así el S.O. ya sabe que hay una survey_channel que se puede configurar por el usuario cuando cierre la app
          await flutterLocalNotificationsPlugin?.cancel(initialSurveyId);
        } catch (e) {
          milog.shout("Error al intentar enviar la notificación de 0s antes de initialSurvey: no es importante: ${e.toString()}");
        }
        // [4] If everything has been completed, initialize all and send to main
        // screen
      } else {
        // Esta es la parte del programa que se va a ejecutar ya siempre una vez
        // que tengamos el code y hayamos contestado al consentimiento y a la initial_survey
        // Store device id in database
        if (!deviceIdUploaded) {
          ultimoMensaje = "storeUser";
          deviceIdUploaded = await storeUser(code, checkConnection: true).timeout(timeoutValue);
        }
        // Request app settings if necessary

        ultimoMensaje = "askForPermissions 2";
        await askForPermissions();

        // Si estamos inyectando la survey, mejor no arrancamos la long_task para poder cerrar el programa fácil
        if (!INYECTAR_SURVEY) {
          ultimoMensaje = "initializeAll";
          await initializeAll().timeout(const Duration(seconds: 60)); // este es un caso especial, ponemos 1 minuto a mano
        }

        // Retrieve survey if available
        if (pendingSurvey) {
          // para evitar que por una notificación externa se haga "pop" en didChangeAppLifecycleState
          // al contestar la encuesta la app ya hace el "pop" en survey_page.dart
          // finalizeApp = false;
          final surveyID = prefs?.getInt(SHARED_SURVEY_ID) ?? 3;
          // si estamos ejecutando esto es porque viene de una notificación ->
          // la quitamos (a no ser que sea una survey inyectada para depuración)
          if (!INYECTAR_SURVEY) {
            try {
              await flutterLocalNotificationsPlugin?.cancel(surveyID);
            } catch (e, s) {
              milog.shout("Error al hacer flutterLocalNotificationsPlugin.cancel en la UI: ${e.toString()} ${s.toString()}");
            }
          }
          ultimoMensaje = "surveyTask";
          final survey = prefs?.getString("$SHARED_SURVEY_$surveyID") ?? "";
          // Si hay cualquier problema, uso el consentTask que tengo almacenado localmente -> con dejar consentTask = null
          // ya se cargará más abajo por defecto el que tenemos guardado en la app
          if (survey != "") {
            try {
              final surveyMap = jsonDecode(survey);
              surveyTask = RPOrderedTask.fromJson(surveyMap['data'] as Map<String, dynamic>);
            } catch (e) {
              surveyTask = null;
              milog.shout("surveyTask = RPOrderedTask.fromJson da un error. Lo pongo a null y saco la que tenemos en la app");
            }
          } else {
            surveyTask = null;
            milog.shout("survey == "
                ". Lo pongo a null y saco la que tenemos en la app");
          }
          if (surveyTask == null) {
            // más adelante, por defecto, van a cargar la daily_survey si surveyTask es null.
            if (surveyID == WEEKLY_SURVEY_ID) {
              // no lo pongo en try-catch porque este se supone que está más que comprobado
              surveyTask = RPOrderedTask.fromJson(jsonDecode(weekly_survey_study2) as Map<String, dynamic>);
            }
          }
        }
      }
      return true;
    } on InvalidCodeException catch (e) {
      milog.shout("Excepción en login: InvalidCodeException. $ultimoMensaje. ${e.toString()}");
      requestAgain = true;
      _showDialog(Strings.invalidCodeError);
      return false;
    } on UnauthorizedException catch (e) {
      milog.shout("Excepción en login: UnauthorizedException. $ultimoMensaje. ${e.toString()}");
      requestAgain = true;
      _showDialog(Strings.invalidCodeError);
      return false;
    } on ServerException catch (e) {
      milog.shout("Excepción en login: ServerException. $ultimoMensaje. ${e.toString()}");
      if (code.isEmpty) {
        requestAgain = true;
        _showDialog(Strings.serverError);
      }
      serviceNotAvailable = true;
      return false;
    } on TimeoutException catch (e) {
      milog.shout("Excepción en login: TimeoutException. $ultimoMensaje. ${e.toString()}");
      if (code.isEmpty) {
        requestAgain = true;
        _showDialog(Strings.serverError);
      }
      serviceNotAvailable = true;
      return false;
    } on Exception catch (e) {
      // cualquier otra excepción ... como si fuera un timeout
      milog.shout("Excepción en login: $ultimoMensaje. ${e.toString()}");
      if (code.isEmpty) {
        requestAgain = true;
        _showDialog(Strings.serverError);
      }
      serviceNotAvailable = true;
      return false;
    }
  }

  /// Widget builder

  // Future<void> arranca() async {
  //   debugPrint("Arrancando");
  //   await initLongTask();
  // }
  //
  // Future<void> stop() async {
  //   debugPrint("Stop");
  //   await stopLongTask(stopServiceToo: false);
  // }
  //
  // Future<void> stopAll() async {
  //   debugPrint("stopAll");
  //   await stopLongTask(stopServiceToo: true);
  // }
  //
  // Future<void> stopAndArranca() async {
  //   debugPrint("stopAndArranca");
  //   await stopLongTask(stopServiceToo: false);
  //   await Future.delayed(const Duration(seconds: 1));
  //   debugPrint("Arrancando");
  //   await initLongTask();
  // }
  //
  // Future<void> stopAllAndArranca() async {
  //   debugPrint("stopAllAndArranca");
  //   await stopLongTask(stopServiceToo: true);
  //   await Future.delayed(const Duration(seconds: 1));
  //   debugPrint("Arrancando");
  //   await initLongTask();
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //         child: Column(
  //       children: [
  //         const SizedBox(height: 50),
  //         ElevatedButton(onPressed: arranca, child: const Text("Arranca")),
  //         const SizedBox(height: 20),
  //         ElevatedButton(onPressed: stop, child: const Text("Envía stop")),
  //         const SizedBox(height: 20),
  //         ElevatedButton(onPressed: stopAll, child: const Text("Para servicio")),
  //         const SizedBox(height: 20),
  //         ElevatedButton(onPressed: stopAndArranca, child: const Text("Envia stop y arranca")),
  //         const SizedBox(height: 20),
  //         ElevatedButton(onPressed: stopAllAndArranca, child: const Text("Para servicio y arranca")),
  //         const SizedBox(height: 20),
  //       ],
  //     )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _miLogin,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Wait for validation
          return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: AutoSizeText(
                        widget.loadingText ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                        maxLines: 2,
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  const CircularProgressIndicator()
                ],
              )));
        } else if (!requestAgain) {
          if (!serviceNotAvailable) {
            if (!consentUploaded & !initialSurveyUploaded) {
              return SurveyPage(
                surveyTask: consentTask ?? RPOrderedTask.fromJson(jsonDecode(informed_consent_study2) as Map<String, dynamic>),
                code: widget.code ?? "",
                surveyType: SurveyType.consent,
              );
            } else if (consentUploaded & !initialSurveyUploaded) {
              return SurveyPage(
                surveyTask: initialSurveyTask ?? RPOrderedTask.fromJson(jsonDecode(initial_survey_study2) as Map<String, dynamic>),
                code: widget.code ?? "",
                surveyType: SurveyType.initial,
              );
            } else {
              return pendingSurvey
                  ? SurveyPage(
                      surveyTask: surveyTask ?? RPOrderedTask.fromJson(jsonDecode(daily_survey_study2) as Map<String, dynamic>),
                      code: widget.code ?? "")
                  : const MainPage();
            }
          } else {
            return ServiceNotAvailablePage(Strings.serviceNotAvailableText, widget.loadingText ?? "", false);
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
