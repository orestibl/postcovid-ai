import 'package:logging/logging.dart';

var milog = Logger("MyLogger");

const bool printRutas = true; //en todos los build, por ejemplo
const bool printWidgetLifeCycle = true;
const bool printAppLifeCycle = true;
const bool useColors = true;
const bool showLevelName = false;
const bool showTime = false;

// void printYellow(String text) {
//   print('\x1B[33m$text\x1B[0m');
// }

// void printRed(String text) {
//   print('\x1B[31m$text\x1B[0m');
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
    var levelName = record.level.name + ": ";
    var time = record.time.toString() + ": ";
    print('${useColors ? color : ""}${showLevelName ? levelName : ""}'
        '${showTime ? time : ""}'
        '${record.message}'
        '${useColors ? reset : ""}');
  }
}
