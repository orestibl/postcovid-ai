import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:research_package/model.dart';
import 'package:research_package/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
// DEFAULT SURVEYS
import '../default/study2/informed_consent_study2.dart';
import '../default/study2/daily_survey_study2.dart';
import '../default/study2/initial_survey_study2.dart';
import '../default/study2/weekly_survey_study2.dart';

import '../../main.dart';
import '../../my_logger.dart';
import '../helper_functions.dart';
import '../strings.dart';
import 'loading_page.dart';

class SurveyPage extends StatelessWidget {
  /// RPOrderedTask to be presented as the survey
  final RPOrderedTask surveyTask;
  final String code;
  final SurveyType surveyType;
  bool resultCallbackLocked = false;

  SurveyPage({super.key, required this.surveyTask, required this.code, this.surveyType = SurveyType.regular});

  Future<void> resultCallback(BuildContext context, RPTaskResult result) async {
    if (resultCallbackLocked == true) {
      milog.info("Han pulsado más de una vez el botón... lo ignoramos");
      return;
    }
    resultCallbackLocked = true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Strings.savingSurveyText),
      duration: const Duration(seconds: 5),
    ));
    // Voy a almacenar también el code en uno de los campos del carpHeader.
    // Dentro de deviceRoleName, le voy a añadir el code
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(SHARED_CODE) ?? "";
    final currentTime = DateTime.now();
    // Create data point
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    final data = await createDataPoint(jsonEncode(result.toJson()), dataType: "survey", code: code, deviceInfo: info.id);
    String jsonEncodedData = json.encode(data.toJson());
    jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "survey_result");
    // Si llegamos aquí es que se ha contestado. El resto ya es nuestro problema
    if (surveyType == SurveyType.regular) {
      await prefs.setInt(SHARED_DATE_LAST_COMPLETED_SURVEY, currentTime.millisecondsSinceEpoch).timeout(timeoutValue);
    }
    bool enviado = false;
    // Upload the result to the database
    // en este caso no queremos que el usuario pierda mucho tiempo. Si no
    // se envía ahora, se enviará desde la long_task
    final success = await sendJsonEncodedDataPoint(jsonEncodedData, code: code, checkConnection: true, maxAttempts: 2, delay: 1);
    if (success) {
      enviado = true;
      milog.info("encuesta enviada con éxito.");
    } else {
      enviado = false; // no hace falta, ya tenía ese valor
      // El mensaje de error ya lo habrá notificado sendJsonEncodeDataPoint -> aquí solo info
      milog.info("Error al intentar enviar la encuesta. Guardo la encuesta en shared_prefs y se enviará después");
    }
    resultCallbackLocked = false;
    // Actualizamos las preferencias compartidas según cómo haya ido la cosa
    if (surveyType == SurveyType.consent) {
      try {
        if (!enviado) {
          // que lo envíe la long_task
          await prefs.setString(SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT, jsonEncodedData).timeout(timeoutValue);
        }
        await prefs.setBool("isConsentUploaded", true).timeout(timeoutValue);
      } catch (e) {
        milog.shout("Fallo en SHARED_CONSENT_SURVEY_PENDING_TO_BE_SENT. Ya más no puedo hacer...");
      }
      // Push main screen
      if (context.mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => LoadingPage(code: code, loadingText: Strings.loadingAppText)));
      }
    } else if (surveyType == SurveyType.initial) {
      try {
        if (!enviado) {
          await prefs.setString(SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT, jsonEncodedData).timeout(timeoutValue);
        }
        await prefs.setBool("isInitialSurveyUploaded", true).timeout(timeoutValue);
      } catch (e) {
        milog.shout("Fallo en SHARED_INITIAL_SURVEY_PENDING_TO_BE_SENT. Ya más no puedo hacer...");
      }

      // Push main screen
      if (context.mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => LoadingPage(code: code, loadingText: Strings.loadingAppText)));
      }
    } else {
      // regular survey: daily or weekly
      try {
        if (!enviado) {
          await prefs.setString(SHARED_SURVEY_PENDING_TO_BE_SENT, jsonEncodedData).timeout(timeoutValue);
        }
      } catch (e) {
        milog.shout("Fallo en SHARED_SURVEY_PENDING_TO_BE_SENT. Ya más no puedo hacer...");
      }
      // HECTOR: este es el sitio correcto para quitarlo. Así la long task sabe que se ha contestado
      // y de paso quito la notificación, si sigue ahí
      if (prefs.containsKey(SHARED_SURVEY_ID)) {
        final surveyID = prefs.getInt(SHARED_SURVEY_ID);
        prefs.remove(SHARED_SURVEY_ID);
        try {
          // mientras haya UI la long_task no va a añadir más -> aquí es un buen momento
          await flutterLocalNotificationsPlugin?.cancel(surveyID ?? 3);
        } catch (e, s) {
          milog.shout("Error al hacer flutterLocalNotificationsPlugin.cancel en la UI: ${e.toString()} ${s.toString()}");
        }
      }

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(Strings.surveySaved),
              content: Text(Strings.pressOk2Exit),
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
      // Ojo, si vas a hacer un pop -> no va a pasar por el dispose de main_page ->
      // deberías a mano poner lo que tengas en dispose
      milog.info("HECTOR: VOY A PONER DE NUEVO LA PÁGINA PRINCIPAL EN LUGAR DE SALIR DEL PROGRAMA. A ver si así queda mejor");
      // await AppClient.sendAppPaused();
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');

      // Push main screen
      if (context.mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => LoadingPage(code: code, loadingText: Strings.loadingAppText)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // const TEST_MODE2 = false;
    if (USAR_ENCUESTAS_DIRECTAMENTE_DE_VARIABLES_JSON) {
      milog.info("HECTOR, ESTOY DEPURANDO LOS JSON!!!");
      // final mySurveyOTMMap = jsonDecode(informed_consent_study2);
      // final mySurveyOTMMap = jsonDecode(initial_survey_study2);
      // final mySurveyOTMMap = jsonDecode(daily_survey_study2);
      final mySurveyOTMMap = jsonDecode(weekly_survey_study2);
      final mySurveyOTM = RPOrderedTask.fromJson(mySurveyOTMMap as Map<String, dynamic>);
      return RPUITask(
        task: mySurveyOTM,
        onSubmit: (result) {
          resultCallback(context, result);
        },
      );
    } else {
      return RPUITask(
        task: surveyTask,
        onSubmit: (result) {
          resultCallback(context, result);
        },
      );
    }
  }
}
