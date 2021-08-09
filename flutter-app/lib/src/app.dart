part of postcovid_ai;

/// APP

// ignore: must_be_immutable
class App extends StatelessWidget {
  String code = "";
  bool _isConnected;

  Future<bool> getCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check internet connection
    try {
      final response = await InternetAddress.lookup("www.google.com");
      if (response.isNotEmpty) {
        _isConnected = true;
      }
    } on SocketException catch (err) {
      _isConnected = false;
      info(err.message);
    }
    // Check if we have the code
    if (prefs.containsKey("code")) {
      code = prefs.getString("code");
      return true;
    } else {
      return false;
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: [
          Locale('es'),
        ],
        localizationsDelegates: [
          AssetLocalizations.delegate,
          RPLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.theme,
        home: FutureBuilder(
            future: getCode(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // Wait till we have the code
                return Scaffold(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator()],
                    )));
              } else {
                // Code is obtained, go to loading page
                return _isConnected
                    ? LoadingPage(text: code)
                    : ServiceNotAvailablePage();
              }
            }));
  }
}

/// Main page

class PostcovidAIApp extends StatefulWidget {
  PostcovidAIApp({Key key}) : super(key: key);

  PostcovidAIAppState createState() => PostcovidAIAppState();
}

class PostcovidAIAppState extends State<PostcovidAIApp> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
  }

  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Strings.appName),
          centerTitle: true,
        ),
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      'Está participando en el estudio POSTCOVID-AI de la Universidad de Granada',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text(
                    'Si experimenta algún problema, puede ponerse en contacto con nosotros a través de la siguiente dirección de correo electrónico:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                      child: Text(Strings.contactEmail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.DARK_COLOR)),
                      onTap: () async {
                        var url = 'mailto:' + Strings.contactEmail;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Cannot launch $url';
                        }
                      })
                ])));
  }

  void stop() {
    setState(() {
      if (bloc.isRunning) bloc.stop();
    });
  }

  void restart() {
    setState(() {
      if (bloc.isRunning)
        bloc.pause();
      else
        bloc.resume();
    });
  }
}
