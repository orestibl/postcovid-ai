import 'package:android_long_task/long_task/app_client.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../long_task_functions.dart';
import '../../main.dart';
import '../app_theme.dart';
import '../strings.dart';

/// Main page

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // sin await
    AppClient.sendAppResumed();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await AppClient.sendAppPaused();
    // esto no es necesario ya que no lo inicializamos nosotros, pero por si acaso
    // if (bloc.isRunning) {
    //   bloc.pause();
    //   bloc.dispose();
    // }
    super.dispose();
  }

  /// App lifecycle state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      await AppClient.sendAppPaused();
      // debugPrint("HECTORHECTOR AppLifecycleState.inactive");
    }
    if (state == AppLifecycleState.resumed) {
      await AppClient.sendAppResumed();
      // debugPrint("HECTORHECTOR AppLifecycleState.resumed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: AutoSizeText(Strings.appName, maxLines: 1),
          centerTitle: true,
          actions: [
            if (SHOW_QUITAR_LONG_TASK)
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: "Finish studio",
                onPressed: () async {
                  // le quito el await a stopLongTask para que se vaya cerrando mientras sacamos la ventana de diálogo
                  stopLongTask(stopServiceToo: true);
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Eliminando proceso en background"),
                        content: const Text(
                            "Pulsa Ok cuando haya desaparecido la notificación principal"),
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
                },
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset('assets/logo/app_icon.png')),
                const SizedBox(height: 20),
                AutoSizeText(Strings.mainPageText1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    maxLines: 4),
                const SizedBox(height: 20),
                AutoSizeText(
                  Strings.mainPageText2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 5,
                ),
                InkWell(
                    child: Text(Strings.contactEmail,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: AppTheme.DARK_COLOR)),
                    onTap: () async {
                      var url = Uri.parse('mailto:${Strings.contactEmail}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Cannot launch $url';
                      }
                    }),
                const SizedBox(height: 30),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: AppTheme.DARK_COLOR,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    child: Text(
                      Strings.close,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void stop() {
    // setState(() {
    //   if (bloc.isRunning) bloc.stop();
    // });
  }

  void restart() {
    // setState(() {
    //   if (bloc.isRunning)
    //     bloc.pause();
    //   else
    //     bloc.resume();
    // });
  }
}
