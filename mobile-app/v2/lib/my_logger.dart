import 'dart:convert';
import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:logging/logging.dart';
import 'credentials.dart';

import 'main.dart';

var milog = Logger("MyLogger");

const bool printRutas = true; //en todos los build, por ejemplo
const bool printWidgetLifeCycle = true;
const bool printAppLifeCycle = true;
const bool useColors = true;
const bool showLevelName = false;
const bool showTime = false;

// void printYellow(String text) {
//   debugPrint('\x1B[33m$text\x1B[0m');
// }

// void printRed(String text) {
//   debugPrint('\x1B[31m$text\x1B[0m');
// }

class MyLogger {
  /*
  Uso habitual:
  En yaml file:
dependencies:
  logging: ^1.0.1

  void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord
      .listen((record) => MyLogger.listen(record));
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final message = "message to be logged";
    milog.shout("$message");
    milog.severe("$message");
    milog.warning("$message");
    milog.info("$message");
    milog.config("$message");
    milog.fine("$message");
    milog.finer("$message");
    milog.finest("$message");
  */
  static const reset = "\x1b[0m";
  static const bright = "\x1b[1m";
  static const dim = "\x1b[2m";
  static const underscore = "\x1b[4m";
  static const blink = "\x1b[5m";
  static const reverse = "\x1b[7m";
  static const hidden = "\x1b[8m";

  static const black = "\x1b[30m";
  static const red = "\x1b[31m";
  static const green = "\x1b[32m";
  static const yellow = "\x1b[33m";
  static const blue = "\x1b[34m";
  static const magenta = "\x1b[35m";
  static const cyan = "\x1b[36m";
  static const white = "\x1b[37m";

  static const BGblack = "\x1b[40m";
  static const BGred = "\x1b[41m";
  static const BGgreen = "\x1b[42m";
  static const BGyellow = "\x1b[43m";
  static const BGblue = "\x1b[44m";
  static const BGmagenta = "\x1b[45m";
  static const BGcyan = "\x1b[46m";
  static const BGwhite = "\x1b[47m";

  static void listen(LogRecord record,
      {bool useColors = useColors,
      bool showLevelName = showLevelName,
      bool showTime = showTime}) {
    String color = "";

    if (useColors) {
      switch (record.level.name) {
        case "SHOUT":
          color = red + bright + BGwhite;
          break;
        case "SEVERE":
          color = red + bright;
          break;
        case "WARNING":
          color = magenta;
          break;
        case "INFO":
          color = yellow;
          break;
        case "CONFIG":
          color = white;
          break;
        case "FINE":
          color = green + bright;
          break;
        case "FINER":
          color = cyan + bright;
          break;
        case "FINEST":
          color = blue + bright;
          break;
        //default: // finest
      }
    }
    var levelName = "${record.level.name}: ";
    var time = "${record.time}: ";
    final message = '${useColors ? color : ""}${showLevelName ? levelName : ""}'
        '${showTime ? time : ""}'
        '${record.message}'
        '${useColors ? reset : ""}';
    if (kDebugMode) {
      debugPrint(message);
    }
    if (record.level.name == "SHOUT") {
      // otra forma de mostrar los errores
      FlutterError.reportError(FlutterErrorDetails(
        exception: record.message,
        library: 'ERROR GORDO',
        context: ErrorSummary('Esto hay que arreglarlo!!!'),
      ));
    }
    if (SEND_SHOUTS_TO_SERVER && record.level.name == "SHOUT") {
      sendLogToServer(message); //no pongo await, se lanza la hebra y se acabó
      // al lanzar la hebra y desentendernos de ella, no puedes poner un try-catch aquí!!!
    }
  }
}

Future<int> sendLogToServer(String message) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(SHARED_CODE);
    String userCode =
        "SIN_USER_CODE"; // por defecto, pongo ese (no sabré quién me lo envía)
    if (code != null && code.length == 10) {
      userCode = code.substring(0, 5);
    }
    final uri = Uri.parse("$apiRestUri/old_api/external_logs");
    Map<String, dynamic> payload = {
      "participantCode": userCode,
      "texto": message
    };
    final response = await http.post(uri,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"}).timeout(timeoutValue);
    return response.statusCode;
    // No miro response.statusCode... este es el último recurso. Si no llega, no llega.
  } catch (e) {
    // si hay cualquier problema, pues nada... no se envía.
    if (kDebugMode) {
      debugPrint(e.toString());
    }
    return -1;
  }
}
