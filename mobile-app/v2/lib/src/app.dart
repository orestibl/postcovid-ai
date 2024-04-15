import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:postcovid_ai_sin_carp/src/strings.dart';
import 'package:postcovid_ai_sin_carp/src/ui/service_not_available_page.dart';
import 'package:research_package/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../my_logger.dart';
import 'app_theme.dart';
import './ui/loading_page.dart';

/// APP

// ignore: must_be_immutable
class App extends StatelessWidget {
  String code = "";
  String loadingText = "";
  bool _isConnected = false;

  App({super.key});

  Future<bool> getCode() async {
    milog.info("Entramos en getCode. ¿Cuántas veces se ejecuta?");
    SharedPreferences? prefs;
    try {
      // si la app estaba frozen, vamos a darle un timeout de... 10s
      prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 10));
    } catch (e) {
      // si falla esto, es como si no tuviéramos red
      _isConnected = false; // ya estaba en false
      return false;
    }
    // if (prefs == null) {
    //   // si falla esto, es como si no tuviéramos red
    //   _isConnected = false; // ya estaba en false
    //   return false;
    // }

    // Get loading text
    loadingText = (prefs.containsKey(SHARED_SURVEY_ID)) ? Strings.loadingSurveyText : Strings.loadingAppText;
    // Check if we have the code
    // Si tenemos el code, da igual que no haya conexión a Internet
    if (prefs.containsKey(SHARED_CODE)) {
      code = prefs.getString(SHARED_CODE) ?? "";
      milog.info("Tenemos code!!!");
      return true;
    } else {
      milog.info("No tenemos code -> chequeamos si hay Internet porque lo vamos a necesitar");
      // Check internet connection
      try {
        final response = await InternetAddress.lookup("www.google.com");
        if (response.isNotEmpty) {
          _isConnected = true;
        }
      } on SocketException catch (err) {
        _isConnected = false;
        milog.info(err.message);
      } on Exception catch (err) {
        // Esto no debería pasar, pero por si acaso...
        _isConnected = false;
        milog.shout(err.toString());
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('es'),
      ],
      localizationsDelegates: [
        // App translations
        //  - the translations of app text is located in the 'assets/lang/' folder
        //  - note that the json files contains a COMBINATION of both app and
        //    translations of the surveys and informed consent in this demo app
        AssetLocalizations.delegate,
        // Research Package translations
        //  - the translations of informed consent and surveys are located in
        //    the 'assets/lang/' folder
        //  - note that only some text is translated -- illustrates that RP
        //    works both with and without translation.
        RPLocalizations.delegate,
        // Built-in localization of basic text for Cupertino widgets
        GlobalCupertinoLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.theme,
      // darkTheme: AppTheme.darkTheme, // mejor no (no sale bien)
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future:
            getCode(), // HECTOR: No conviene usar una función en future: de FutureBuilder. Al ser StatelessWidget no es un problema (parece)
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // HECTOR: Como miro "hasData" esto se va a ejecutar aunque esté en waiting si se ejecutó la vez anterior -> a pesar de eso, se ejecuta getCode de nuevo, pero no es tan dañino
            // Wait till we have the code
            return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: const Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator()],
                )));
          } else {
            if (code != "" || _isConnected) {
              return LoadingPage(code: code, loadingText: loadingText);
            } else {
              return ServiceNotAvailablePage(Strings.connectionNotAvailableText, loadingText, true);
            }
          }
        },
      ),
    );
  }
}
