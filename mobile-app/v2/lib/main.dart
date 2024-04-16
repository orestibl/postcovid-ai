import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:light/light.dart';
import 'package:logging/logging.dart';
import 'package:noise_meter/noise_meter.dart';
// import 'package:noise_meter/noise_meter.dart';
import 'package:postcovid_ai_sin_carp/src/app.dart';
import 'package:postcovid_ai_sin_carp/src/carp_backend/http_retry.dart';
import 'package:screen_state/screen_state.dart';

import 'long_task_functions.dart';
import 'long_task_main.dart';
import 'my_logger.dart';

// VARIABLES Y CONSTANTES GLOBALES: PREFIERO PONERLAS AQUI A METERLAS DENTRO DE UNA CLASE "Global" COMO STATIC
enum SurveyType { consent, initial, regular }

List<String> listaDataPoints = [];
StreamSubscription<ConnectivityResult>? connectivitySubscription2;
StreamSubscription<ScreenStateEvent>? screenStateSubscription;
StreamSubscription<Activity>? activitySubscription;
StreamSubscription<int>? lightSubscription;
StreamSubscription<NoiseReading>? noiseSubscription;
NoiseMeter? noiseMeter;
Map<String, String> lastWatchDogReceivedByUuid = {'unknown': '', 'any': ''};
// Si USE_SCREEN_STATE, esta variable se va actualizando y la puedes usar para hacer ciertas cosas (p.ej. solo medir el ruido si el móvil está OFF)
var lastScreenState = ScreenStateEvent.SCREEN_UNLOCKED;
String longTaskUuid = "";
bool canUseNoiseMeter = true; //inicialmente true para intentarlo
FlutterActivityRecognition activityRecognition = FlutterActivityRecognition.instance;
var light = Light();
final HTTPRetry httpr = HTTPRetry();
AppServiceData appServiceData = AppServiceData(); // esta variable la usa la UI y la long task (pero son diferentes)
// ActivityRecognition activityRecognition = ActivityRecognition.instance;
// // pra poder acceder a las notificaciones desde cualquier page de la UI.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
// HECTOR: Para depuración del programa
const NUM_MAX_CHARS_DEVICE_INFO = 1024; // ACUÉRDATE DE RECOMPILAR EL SERVIDOR PARA PERMITIR 1024!!!
// Si SHOW_QUITAR_LONG_TASK, en main_page.dart se mostrará también un icono para cerrar el servicio de la long_task
const SHOW_QUITAR_LONG_TASK = false;
// Si MOSTRAR_INFO es true, se hacen updates de appServiceData.mensaje con info de la app. Si es false, solo se muestra "Funcionamiento correcto". En cualquier caso, siempre se actualiza el watch dog en cada iteración.
const MOSTRAR_INFO = false;
const ACELERAR_TIEMPOS_PARA_DEPURAR_SURVEYS = false;
const INYECTAR_SURVEY = false;
const SURVEY_INYECTADA = 3; // Uno de los "id" de la tabla "documents" de la BD
const USAR_ENCUESTAS_DIRECTAMENTE_DE_VARIABLES_JSON = false;
const SALTARSE_INITIAL_SURVEY = false; // para debug (no tener que pasar por el latazo de contestarla)
// Esto es para depurar paso a paso sin que los timeouts me salten -> pon false en producción
const USE_LONG_TIMEOUT = false;
const MI_TIMEOUT = USE_LONG_TIMEOUT ? 120 : 40; // con 30 de vez en cuando se vía un timeout...
const Duration timeoutValue = Duration(seconds: MI_TIMEOUT); // HECTOR

const IGNORAR_CERTIFICADO_SSL = false; // es peligroso poner true, pero si prevés que el certificado pueda caducar... no hay más remedio
const RUN_LONG_TASK = true;
const USE_AR = true;
const FILTRAR_DATOS_AR_SEGUIDOS = true;
// Si USE_AR y FILTRAR_DATOS_AR_SEGUIDOS -> se mira NUM_MS_MINIMO_ENTRE_MUESTRAS_IGUALES
const NUM_MS_MINIMO_ENTRE_MUESTRAS_IGUALES = 500;
const USE_CONNECTIVITY = true;
const USE_WIFI_INFO = true;
const ENCRYPT_WIFI_INFO = true;
const USE_SCREEN_STATE = true;
// Si CHECK_SDK_VERSION_TO_REMOVE_NOISE_METER es true -> se quita NOISE_METER para SDK>=30
const CHECK_SDK_VERSION_TO_REMOVE_NOISE_METER = false;
bool USE_NOISE_METER = true; // lo uso como variable porque si sdk>=30 lo pongo a false
const USE_LIGHT = true;
// si USE_LIGHT, cada este tiempo se hace una medición de la luz durante DURATION_SAMPLING_LIGHT segundos
const DELTA_LIGHT_MEASURE = 5 * 60 * 1000; // cada 5 minutos
const LIGHT_SAMPLING_DURATION_SECONDS = 1;
const DELTA_NOISE_MEASURE = 5 * 60 * 1000; // cada 5 minutos
const NOISE_SAMPLING_DURATION_SECONDS = 2; // pongo 2 s para minimizar problemas (consensuado con Oresti)

const SEND_SHOUTS_TO_SERVER = true;
// Para permitir que alguien conteste una weekly survey que se le haya pasado
// lo que voy a hacer es permitir que en el scheduling de surveys
// se pueda poner que la survey 4 (la weekly) survey se pueda poner en varios días seguidos,
// de tal forma que si no se contestó un día, se pueda hacer al día siguiente.
// Para surveys tipo 3 y, en general, si han pasado más de 12 horas desde que se contestó la encuesta de las xxx horas
// Obviamente, si fue ayer habrán pasado unas 24 y si ha sido hoy habrán
// pasado como mucho 60 minutos -> con 12 horas es suficiente para distinguir los dos casos
const deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysHorarias = 12 * 60 * 60 * 1000;
// Para surveys tipo 4 (weekly survey), si han pasado más de 5 días y medio de la última vez que se contestó
// permitimos que salga de nuevo:
// OJO, survey semanal en long_task_main.dart se considera que es la nº 4!!!!
const deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysSemanales = 5 * 24 * 60 * 60 * 1000 + 12 * 60 * 60 * 1000;
// Si INICIALIZAR_INITIAL_SURVEY_COMO_WEEKLY_SURVEY = true, consideramos la respuesta de la initial_survey
// (en realidad directamente mito que no exista la preferencia compartida SHARED_COMPLETED_SURVEYS
// que solo ocurre, en principio, al comienzo de tot, cuando se contesta la initial_survey
// En ese caso, ponemos en completedSurveys[HORA_WEEKLY_SURVEY] la hora a la que esto ocurre
// Con eso, evitamos que se conteste una weekly survey demasiado cercana a la initial_survey
// Debe pasar, como mínimo, deltaUltimaSurveyContestadaParaConsiderarYaCaducadaSurveysSemanales ms
const INICIALIZAR_INITIAL_SURVEY_COMO_WEEKLY_SURVEY = false;
const HORA_WEEKLY_SURVEY =
    18; // todo: podíamos obtener esta hora a la que se pasa la weekly survey de forma automática... A partir de defaultStudySurveysJson!!!
// Si durante MAX_SECONDS_WATCH_DOG_LONG_TASK_CONSIDERED_CRASHED no ha dado señales de vida-> la próxima vez que el
// usuario ejecute la app se reiniciará el servicio y se creará una nueva long_task
// (aunque antes le daremos la orden de parar por si seguía viva)
const MAX_SECONDS_WATCH_DOG_LONG_TASK_CONSIDERED_CRASHED =
    7200; //3600 (algunos S.O. pueden congelar la app más de 1 hora sin que haya crasheado)
// Si tras un UiPresent no viene un Not UiPresent después de este tiempo, lo pongo
// yo a mano. Te en cuenta que si hay UiPresent no comprobamos si hay encuestas
const MAX_SECONDS_SEGUIDOS_UI_PRESENT = 240; //240
const NUM_SECONDS_MAIN_LOOP_LONG_TASK = 10;
// Inicialmente, la idea era retrasar la entrada en el bucle hasta que se cerrara
// la app. Pero da igual ya que si hay Ui no notifico
// (al menos, hasta un límite marcado por MAX_SECONDS_SEGUIDOS_UI_PRESENT)
const DELAY_ANTES_BUCLE_PRINCIPAL_LONG_TASK = 5;
const LOG_WATCH_DOG = "WATCH_DOG";

// las encuestas se contestan a partir de la hora que indica el servidor más
// un número aleatorio de minutos entre 0 y MAX_OFFSET_MINUTOS_SURVEY (para evitar
// que todas lleguen a la vez al servidor)
const MAX_OFFSET_MINUTOS_SURVEY = 5;
// se chequea si hay una nueva survey cada DELTA_SURVEY_CHECK ms
const DELTA_SURVEY_CHECK = 5 * 60 * 1000; // cada 5 minutos
// se chequea si debemos auto-matarnos (por si acaso...)
const DELTA_SELF_KILL_CHECK = 5 * 60 * 1000; // cada 5 minutos
// se actualiza el WatchDog en SHARED_PREFS cada DELTA_WATCH_DOG_CHECK ms (el otro, el de las notificaciones se actualiza en cada iteración de la long task). Este debe ser menos frecuente porque usa el disco... (aunque en realidad usaría la caché...)
const DELTA_WATCH_DOG_CHECK = 5 * 60 * 1000; // cada 5 minutos
// se intenta volver a preguntar al servidor por el scheduling de las encuestas
// por si se actualiza desde el servidor una vez comenzado el estudio cada DELTA_SURVEYS_DOWNLOAD ms
const DELTA_SURVEYS_SCHEDULING_DOWNLOAD = 1 * 60 * 60 * 1000; // cada hora (me lo han pedido así)
// se intenta volver a preguntar al servidor por las encuestas 3 y 4, por si se actualiza desde el servidor una vez comenzado el estudio cada DELTA_SURVEYS_DOWNLOAD ms
const DELTA_DOCUMENTS_DOWNLOAD = 1 * 60 * 60 * 1000; // cada hora (me lo han pedido así)
// Tras recibir una notificación de que nos hemos quedado sin conexión de red, volvemos a comprobar
// si la hemos recuperado cada ese tiempo (prefiero hacerlo así a dejar un listener para no estar
// haciendo cosas intermitentes)
const DELTA_RECHECK_CONNECTIVITY = 1 * 60 * 1000; // cada minuto
// Cada cierto tiempo, aunque estemos conectados, volvemos a comprobar que tenemos Internet y acceso al servidor
const DELTA_CHECK_SERVER_CONNECTED = 5 * 60 * 1000; // cada 5 minutos
// Cada vez que recopilemos estos data points, se añaden en la variable compartida SHARED_DATA_POINTS_TO_BE_SENT para ser enviados en cuanto haya conexión con el servidor
const MIN_NUM_DATA_POINTS_TO_BE_STORED = 10;
// Y este es el valor máximo de data_points que se envían en un batch (un valor razonable para los timeouts que uso)
const BATCH_MAX_NUM_DATA_POINTS_TO_BE_SENT = 100;
// La primera vez que ejecutamos la app, si hay red, descargamos las encuestas desde
// la 1 hasta la MaxSurveyIdToDownloadAtStart y las guardamos en shared_prefs SHARED_SURVEY_{NUM_ENCUESTA}
const MAX_SURVEY_ID_TO_DOWNLOAD_AT_START = 4;
const WEEKLY_SURVEY_ID = 4;
// Como mucho vamos a seguir enviando notificaciones de que la encuesta no se ha
// contestado ese número de minutos.
const MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_DAILY = 75; // 75
const MAX_MINUTOS_ESPERANDO_PENDING_SURVEY_WEEKLY = 180; // Pero que no se solapen con la otra!!!
// OJO, medidos según como indique la siguiente variable.
// Si vale true, será desde las 10:00 (si la encuesta está programada a las 10h).
// Si vale false, será desde el momento en el que se notifica al usuario por primera vez
// Esto último tiene un riesgo y es que, en la semanal, si pones 180 minutos y que empiece a las 17h, por ejemplo, si el usuario tiene
// la app congelada y se entera a las 19:50 -> todavía está dentro del periodo y se le va a extender hasta las 22:50, solapándose con la
// siguiente -> un riesgo!!! hasta que eso no lo hayas resuelto, mejor no lo hagas (p.ej. puedes dar prioridad a las weekly y si hay una
// pendiente, no mirar la otra).
const COMENZAR_A_ESPERAR_PENDING_SURVEY_DESDE_LA_HORA_EN_PUNTO_Y_NO_DESDE_PRIMERA_NOTIFICACION = true;

// SHARED_PREFS_STRINGS (las que puedan ser conflictivas porque las usen dos partes diferentes del programa)
// guardamos el tipo de encuesta que hay que contestar
const SHARED_SURVEY_ID = "surveyID";
// llevamos la cuenta de la última vez que se contestó la survey de cada hora posible del día (suponemos que no habrá dos en la misma hora)
const SHARED_COMPLETED_SURVEYS = "completedSurveys";
// las que se cogen del servidor. Se actualiza cada DELTA_SURVEYS_DOWNLOAD o cada vez que arranca la long_task.
const SHARED_STUDY_SURVEYS = "studySurveys";
// ahí se guarda la fecha en la que se contestó la última survey
const SHARED_DATE_LAST_COMPLETED_SURVEY = "DateLastCompletedSurvey";
// por si hay un error de envío al servidor, se guarda ahí a ver si la long_task puede enviarla en otro momento
const SHARED_SURVEY_PENDING_TO_BE_SENT = "SurveyPendingToBeSent";
const SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT = "ConsentSurveyPendingToBeSent";
const SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT = "InitialSurveyPendingToBeSent";
const SHARED_IS_DEVICE_ID_UPLOADED = "isDeviceIdUploaded";
const SHARED_DATA_POINTS_TO_BE_SENT = "DataPointsPendingToBeSent";
// El código del usuario
const SHARED_CODE = "code";
// El time zone
const SHARED_TIME_ZONE = "timeZone";
const SHARED_SURVEY_ = "SharedSurvey";
const SHARED_LT_UUID_LIST = "long_task_uuid_list";
const SHARED_LT_UUID_LIST_TO_BE_KILLED = "long_task_uuid_list_to_be_killed";

// Para ignorar el certificado SSL del servidor (debes poner IGNORAR_CERTIFICADO_SSL = true)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    MyLogger.listen(record, useColors: true, showLevelName: true, showTime: true);
  });
  if (IGNORAR_CERTIFICADO_SSL) HttpOverrides.global = MyHttpOverrides();
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).timeout(const Duration(seconds: 2));
  } catch (e) {
    // no hacemos nada
    milog.shout("timeout en setPreferredOrientations");
  }
  runApp(App());
}

@pragma('vm:entry-point')
serviceMain() async {
  await serviceMain2();
}
