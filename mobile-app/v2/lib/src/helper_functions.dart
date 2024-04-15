// Checks internet connection
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../credentials.dart';
import '../main.dart';
import '../my_logger.dart';
import 'carp_backend/carp_backend_modificado.dart';
import 'datapoint/datapoint.dart';
import 'exceptions.dart';

void debugPrintWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}

Future<DataPoint> createDataPoint(String dataString,
    {required String code, required String deviceInfo, String dataType = "Unknown"}) async {
  final currentTime = DateTime.now();
  // final horaLocal = "${currentTime.hour}:${currentTime.minute}:${currentTime.second}";
  // final currentTimeUtcMillis = currentTime.millisecondsSinceEpoch; // no hace falta .toUtc(), ya se expresa desde ese momento
  DataPoint data = DataPoint.fromData(Data(id: const Uuid().v4(), datameasured: dataString))
    ..carpHeader.studyId = code.substring(5, 10)
    ..carpHeader.userId = code.substring(0, 5)
    ..carpHeader.dataFormat = DataFormat("ugr", dataType)
    // aquí meto el uuid de la long_task para saber si cambia a lo largo del experimento (se reinicia el móvil...)
    // si se envía, como es el caso de las encuestas, de la UI, este valor será '' (no tiene sentido forzar al valor appServiceData.uuid)
    ..carpHeader.triggerId = longTaskUuid
    // HECTOR, NO PUEDES AÑADIR ALEGREMENTE CAMPOS AL HEADER PORQUE EL SERVIDOR NO TE DEJA!!! HAY QUE HACERLO CON MÁS CUIDADO
    // ..carpHeader.localTime = currentTime.toString()
    // ..carpHeader.utcTime = currentTime.toUtc().toString()
    ..carpHeader.deviceRoleName =
        "LocalTime: ${currentTime.toString()} -- UtcTime: ${currentTime.toUtc().toString()} -- DeviceId: $deviceInfo";
  // milog.info("HECTOR: Creamos nuevo DataPoint: ${jsonEncode(data.toJson())}");
  return data;
}

Future<String> getSurveysJsonFromAPIREST(String code) async {
  // HECTOR: Ahora se accede a la "nueva API" integrada dentro del propio servidor de carp
  final uri = Uri.parse("$apiRestUri/old_api/study_surveys/?studyCode=$code");
  final response = await http.get(uri, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 500 || response.statusCode == 503) {
    milog.warning("getSurveysJsonFromAPIREST, code = $code, response.statusCode = ${response.statusCode} -> throw ServerException");
    throw ServerException();
  } else {
    if (response.statusCode == 200) {
      return response.body;
    } else {
      milog.warning("getSurveysJsonFromAPIREST, code = $code, response.statusCode = ${response.statusCode} -> throw InvalidCodeException");
      throw InvalidCodeException();
    }
  }
}

Future<Map> getStudyFromAPIREST(String code) async {
  // HECTOR: Ahora se accede a la "nueva API" integrada dentro del propio servidor de carp
  final uri = Uri.parse("$apiRestUri/old_api/study_details/get_study");
  Map<String, dynamic> payload = {"code": code};
  final response = await http.post(uri, body: jsonEncode(payload), headers: {"Content-Type": "application/json"});
  if (response.statusCode == 500 || response.statusCode == 503) {
    milog.warning("getStudyFromAPIREST, code = $code, response.statusCode = ${response.statusCode} -> throw ServerException");
    throw ServerException();
  } else {
    if (response.statusCode == 200) {
      final Map jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      milog.shout("getStudyFromAPIREST, code = $code, response.statusCode = ${response.statusCode} -> throw InvalidCodeException");
      throw InvalidCodeException();
    }
  }
}

Future<bool> isConnected() async {
  try {
    final response = await InternetAddress.lookup("www.google.com");
    return response.isNotEmpty ? true : false;
  } on SocketException catch (err) {
    milog.info(err.message);
    return false;
  }
}

// Esto creo que es menos invasivo.Copio este ejemplo del paquete internet_connection_checker
const int DEFAULT_PORT = 53; // 443
const DEFAULT_ADDRESS = '8.8.4.4';
Future<bool> isHostReachable({String address = DEFAULT_ADDRESS, int port = DEFAULT_PORT, int timeoutInSeconds = 10}) async {
  Socket? sock;
  try {
    sock = await Socket.connect(
      address,
      port,
      timeout: Duration(seconds: timeoutInSeconds),
    )
      ..destroy();
    return true;
  } catch (e) {
    sock?.destroy();
    return false;
  }
}

Future<bool> isServerResponding({int timeoutInSeconds = 10}) async {
  try {
    final uri = Uri.parse("$apiRestUri/old_api/completed_surveys/server_alive");
    final response = await http.get(uri).timeout(Duration(seconds: timeoutInSeconds));
    if (response.statusCode == 200) {
      return true; //if (response.body == "ALIVE") return true;
    }
  } catch (e) {
    debugPrint("isServerResponding: false: ${e.toString()}");
    return false;
  }
  return false;
}

// Store user and device IDs in database
Future<bool> storeUser(String code, {bool checkConnection = true}) async {
  // final uri = Uri.parse(apiRestUri + "/register_device");
  if (checkConnection) {
    if ((await Connectivity().checkConnectivity() != ConnectivityResult.none) && await isHostReachable() && await isServerResponding()) {
      // hay conexión -> seguimos
    } else {
      milog.info("sendJsonEncodedDataPoint: no hay conexión con el servidor -> hay que esperar a otro momento");
      return false;
    }
  }
  Uri? url;
  try {
    url = Uri.parse(Uri.encodeFull("$apiRestUri/old_api/participant_device/register_device"));
  } on FormatException catch (e) {
    milog.shout("Uri.parse(Uri.encodeFull($apiRestUri/old_api/participant_device/register_device) devuelve error: ${e.toString()}");
    return false;
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
  String deviceInfo =
      "v:${info.version.sdkInt},b:${info.brand},d:${info.device},di:${info.display},i:${info.id},m:${info.manufacturer},mo:${info.model},p:${info.product}";
  if (deviceInfo.length > NUM_MAX_CHARS_DEVICE_INFO) {
    deviceInfo = deviceInfo.substring(0, NUM_MAX_CHARS_DEVICE_INFO);
  }
  // Aprovecho para meter toda la info que tenemos. En los data_points solo enviaremos el "info.id"
  // He probado a poner caracteres raros y también llegan sin problema -> creo que podemos confiar en que esto no dé problemas
  Map<String, dynamic> payload = {
    "participantCode": code.substring(0, 5),
    "deviceId": deviceInfo
    // "deviceId": prefs.getString('postcovid-ai.user_id') ?? "NO_USER_ID"
  };
  final response = await http.post(url, body: jsonEncode(payload), headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200 || response.statusCode == 201) {
    await prefs.setBool(SHARED_IS_DEVICE_ID_UPLOADED, true).timeout(timeoutValue, onTimeout: () {
      milog.shout("prefs.setBool(SHARED_IS_DEVICE_ID_UPLOADED) -> timeout");
      return false;
    });
    return true;
  } else {
    // throw ServerException();
    milog.shout("storeUser, statusCode != 200 o 201");
    return false;
  }
}

Future<bool> sendJsonEncodedDataPoint(String jsonEncodedDataToBeSent,
    {Map<dynamic, dynamic>? studyCredentials,
    bool checkConnection = true,
    String code = "",
    int maxAttempts = 3,
    int delay = 5,
    int timeout = MI_TIMEOUT}) async {
  if (checkConnection) {
    if ((await Connectivity().checkConnectivity() != ConnectivityResult.none) && await isHostReachable() && await isServerResponding()) {
      // hay conexión -> seguimos
    } else {
      milog.info("sendJsonEncodedDataPoint: no hay conexión con el servidor -> hay que esperar a otro momento");
      return false;
    }
  }
  try {
    if (CarpService().currentUser == null || (CarpService().currentUser?.token?.hasExpired ?? true)) {
      if (studyCredentials == null) {
        if (code == "") {
          milog.shout(
              "sendJsonEncodedDataPoint: studyCredentials es null y code = '', y los necesitamos porque no hay token válido!!!. Salimos");
          return false;
        }
        try {
          studyCredentials = await getStudyFromAPIREST(code).timeout(timeoutValue);
        } catch (e) {
          milog.shout("sendJsonEncodedDataPoint: fallo al hacer getStudyFromAPIREST. code = $code, e=${e.toString()}");
          return false;
        }
      }
      await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);
    }
    const dataEndpointUri = "$serverUri/api/deployments/null/data-points";
    final response = await httpr.post(Uri.encodeFull(dataEndpointUri),
        headers: CarpService().headers, body: jsonEncodedDataToBeSent, maxAttempts: maxAttempts, delay: delay, timeout: timeout);
    int httpStatusCode = response.statusCode;
    Map<String, dynamic> responseJson = json.decode(response.body);
    if ((httpStatusCode == HttpStatus.ok) || (httpStatusCode == HttpStatus.created)) {
      milog.info("Post realizado con éxito. ID del nuevo elemento insertado: ${responseJson["id"]}");
      return true;
    } else {
      if ((httpStatusCode == HttpStatus.badRequest) || (httpStatusCode == HttpStatus.notFound)) {
        milog.shout(
            "sendJsonEncodedDataPoint: recibimos httpStatusCode = ${httpStatusCode.toString()}. Como no es un fallo del servidor, devuelvo true para eliminar ese datapoint");
        return true;
      } else {
        // All other cases are treated as an error. Esta excepción se captura en el catch de abajo
        throw CarpServiceException(
          httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
          // message: responseJson["message"],
          // path: responseJson["path"],
        );
      }
    }
  } catch (e) {
    milog.shout("sendJsonEncodedDataPoint: Excepción!!! Devolvemos false. Error = ${e.toString()}");
    return false;
  }
}

Future<bool> sendJsonEncodedDataPointsBatch(List<String> jsonEncodedDataPointsToBeSent,
    {Map<dynamic, dynamic>? studyCredentials, bool checkConnection = true}) async {
  if (studyCredentials == null) {
    milog.info("sendJsonEncodedDataPointsBatch: studyCredentials es null!!!. Salimos");
    return false;
  }
  if (checkConnection) {
    if ((await Connectivity().checkConnectivity() != ConnectivityResult.none) && await isHostReachable() && await isServerResponding()) {
      // hay conexión -> seguimos
    } else {
      milog.info("sendJsonEncodedDataPointsBatch: no hay conexión con el servidor -> hay que esperar a otro momento");
      return false;
    }
  }
  try {
    if (CarpService().currentUser == null || (CarpService().currentUser?.token?.hasExpired ?? true)) {
      await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);
    }
    const dataEndpointBatchUri = "$serverUri/api/deployments/null/data-points/batch";
    try {
      // var newList = [];
      // for (var k = 1; k <= 1000; k++) {
      //   newList = newList + jsonEncodedDataPointsToBeSent;
      // }
      // var cadena = newList.toString().replaceAll("}}]", "}},{}]");
      var cadena = jsonEncodedDataPointsToBeSent.toString().replaceAll("}}]", "}},{}]");
      int longitud = jsonEncodedDataPointsToBeSent.length;
      int timeoutAdicional = MI_TIMEOUT + 1 * (longitud ~/ 10); // por cada 10 muestras añado 1s
      if (timeoutAdicional >= 300) {
        // valor máximo -> al ser tot síncrono, no podemos interferir en el resto (ya he limitado el tamaño de las muestras en la función que llama a ésta)
        timeoutAdicional = 300;
      }
      milog.info("longitud = $longitud bytes -> estimo el timeout: $timeoutAdicional!!!");
      final success = await httpr.batchPostDataLongString(cadena, dataEndpointBatchUri, CarpService().headers,
          maxAttempts: 2, delay: 60, timeoutSeconds: timeoutAdicional);
      return success;
    } catch (e) {
      debugPrint("Hubo un error al llamar a batchPostDataPointLongString: HAY QUE INTENTARLO EN OTRO MOMENTO: error = ${e.toString()}");
      return false;
    }
  } catch (e) {
    milog.shout("sendJsonEncodedDataPointsBatch: fallo!!! Devolvemos false. Error = ${e.toString()}");
    return false;
  }
}

// Future<int> getSurveyID() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String code = prefs.getString(SHARED_CODE);
//   final uri = Uri.parse(apiRestUri + "/get_survey_id");
//   Map<String, dynamic> payload = {"code": code};
//   final response = await http.post(uri,
//       body: jsonEncode(payload), headers: {"Content-Type": "application/json"});
//   if (response.statusCode == 500 || response.statusCode == 503) {
//     throw new ServerException();
//   } else {
//     Map jsonResponse = jsonDecode(response.body);
//     if (response.statusCode != 200 || jsonResponse['status'] != 200) {
//       return null;
//     } else {
//       return jsonResponse['data']['survey_id'];
//     }
//   }
// }
// Future<Map> getStudyFromAPIREST(String code) async {
//   final uri = Uri.parse(apiRestUri + "/get_study");
//   Map<String, dynamic> payload = {"code": code};
//   final response = await http.post(uri,
//       body: jsonEncode(payload), headers: {"Content-Type": "application/json"});
//   if (response.statusCode == 500 || response.statusCode == 503) {
//     throw new ServerException();
//   } else {
//     Map jsonResponse = jsonDecode(response.body);
//     if (jsonResponse['status'] == 500) {
//       throw new ServerException();
//     } else if (jsonResponse['status'] == 400) {
//       throw new InvalidCodeException();
//     } else if (jsonResponse['status'] == 403) {
//       throw new UnauthorizedException();
//     } else {
//       return jsonResponse['data'];
//     }
//   }
// }
