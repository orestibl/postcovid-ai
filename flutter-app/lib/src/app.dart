part of postcovid_ai;

/// APP

// ignore: must_be_immutable
class App extends StatelessWidget {
  String code = "";
  String loadingText;
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
    // Get loading text
    loadingText = (prefs.containsKey("surveyID"))
        ? Strings.loadingSurveyText
        : Strings.loadingAppText;
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
                    ? LoadingPage(text: code, loadingText: loadingText)
                    : ServiceNotAvailablePage(Strings.connectionNotAvailableText, loadingText, true);
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
          title: AutoSizeText(Strings.appName, maxLines: 1),
          centerTitle: true,
        ),
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: 200,
                      height: 200,
                      child: Image.asset('assets/logo/app_icon.png')),
                  SizedBox(height: 20),
                  AutoSizeText(
                      Strings.mainPageText1,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                      maxLines: 4
                  ),
                  SizedBox(height: 20),
                  AutoSizeText(
                    Strings.mainPageText2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                    maxLines: 5,
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
                    }),
                  SizedBox(height: 30),
                  Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: AppTheme.DARK_COLOR,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                          onPressed: () {
                            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                          },
                          child: Text(
                            Strings.close,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18),
                          )
                      )
                  )
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
