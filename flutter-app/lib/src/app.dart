part of postcovid_ai;

/// APP

// ignore: must_be_immutable
class App extends StatelessWidget {
  String code = "";

  Future<bool> getCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
                return LoadingPage(text: code);
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
  int _selectedIndex = 0;

  final _pages = [HomePage(), TaskList()];

  void initState() {
    if (!Settings().preferences.containsKey("isInitialSurveyUploaded")) {
      //TODO: uncomment for production
      //showInitialSurvey();
      //Settings().preferences.setBool("isInitialSurveyUploaded", true);
      //Settings().preferences.remove("initialSurveyID");
    }
    super.initState();
  }

  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.spellcheck), label: 'Surveys')
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: restart,
        tooltip: 'Restart study & probes',
        child: bloc.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  Future<void> showInitialSurvey() async {
    DocumentSnapshot initialSurvey = await CarpService().documentById(Settings().preferences.getInt("initialSurveyID")).get();
    RPOrderedTask initialSurveyTask = RPOrderedTask.fromJson(initialSurvey.data);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SurveyPage(surveyTask: initialSurveyTask, code: Settings().preferences.getString("code"))
    ));
  }
}
