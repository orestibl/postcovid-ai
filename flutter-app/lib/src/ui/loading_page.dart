part of postcovid_ai;

class LoadingPage extends StatefulWidget {
  final String text;

  LoadingPage({Key key, this.text}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

/// This page will be called 4 times:
/// 1 - Diplay login page
/// 2 - Present the informed consent (only backend initialized)
/// 3 - Present the initial survey
/// 4 - Show main screen (foreground service initialized)

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver{

  // Workflow flags
  bool skipConsent = false;
  bool consentUploaded = false;
  bool initialSurveyUploaded = false;
  bool deviceIdUploaded = false;
  bool pendingSurvey = false;
  bool requestAgain = false;
  bool serviceNotAvailable = false;

  // Extra flags
  bool timeoutReached = false;
  bool finalizeApp = false;

  // Survey tasks
  RPOrderedTask consentTask;
  RPOrderedTask initialSurveyTask;
  RPOrderedTask surveyTask;

  // Other objects
  static const Duration timeoutValue = Duration(seconds: 10);
  Stream<ActivityEvent> activityStream;
  StreamSubscription<Map<String, dynamic>> miLongTaskStreamSuscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// App lifecycle state

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      AppClient.sendAppPaused(); //TODO this closes surveys when opened
      if (finalizeApp) {
        SystemNavigator.pop();
      }
    }
    if (state == AppLifecycleState.resumed) {
      AppClient.sendAppResumed();
    }
    if (state == AppLifecycleState.detached) {
      miLongTaskStreamSuscription?.cancel();
      miLongTaskStreamSuscription = null;
    }
  }

  /// Executed before the loading page is displayed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    miLongTaskStreamSuscription = getLongTaskStreamSuscription();
    isServiceRunning().then((running) {
      if (running) {
        startService(null);
      }
    });
    AppClient.sendAppResumed();
    initializeNotifications();
  }

  // Start foreground service
  void startService(AppServiceData appServiceData) async {
    try {
      await AppClient.startService(appServiceData);
    } on PlatformException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }

  // Initialize notifications
  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Long task logger
  StreamSubscription<Map<String, dynamic>> getLongTaskStreamSuscription() {
    try {
      return AppClient.observe.listen((json) {
        milog.info("AppClient recibe lo siguiente: $json");
      });
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
      return null;
    }
  }

  /// Initialization functions

  Future<void> initStudy({Map studyCredentials}) async {
    if (studyCredentials != null) {
      await bloc.initialize();
      await CarpBackend().initialize(credentials: studyCredentials);
      await Sensing().initialize(credentials: studyCredentials);
    }
  }

  Future<void> initializeAll(Map studyCredentials) async {
    await initStudy(studyCredentials: studyCredentials);
    await initActivityTracking();
    await prepareLongTask(appServiceData);
    await Future.delayed(Duration(milliseconds: 500));
    await runLongTask();
    finalizeApp = true;
  }

  /// Activity recognition

  Future<void> initActivityTracking() async {
    // Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }
    // iOS does not
    else {
      _startTracking();
    }
  }

  void _startTracking() {
    milog.shout(
        "HECTOR: _startTracking ahora llamo a startStream de main.dart.");
    if (activityStream == null) {
      activityStream =activityRecognition.startStream(runForegroundService: false);
      activityStream.listen(null);
    }
  }

  void onData(ActivityEvent activityEvent) {
    milog.info("NEW ACTIVITY: ${activityEvent.toString()}");
  }
  Future<void> prepareLongTask(AppServiceData appServiceData) async {
    if (await isServiceRunning()) {
      return;
    }
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appServiceData.mensaje = packageInfo.packageName;
      await AppClient.startService(appServiceData);
      await AppClient.prepareExecute();
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
  }

  /// Foreground service

  // Checks if the service is running
  Future<bool> isServiceRunning() async {
    try {
      return await AppClient.isServiceRunning();
    } on PlatformException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
    }
  }

  Future<void> runLongTask() async {
    try {
      AppClient.execute();
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
  }

  /// FutureBuilder function

  Future<bool> login(BuildContext context, String code) async {
    try {
      // [1] If the code has not been received, redirect to login page
      if (code.isEmpty) {
        requestAgain = true;
        return true;
      }

      // Check if consent and initial survey have been uploaded
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      consentUploaded = prefs.containsKey("isConsentUploaded");
      initialSurveyUploaded = prefs.containsKey("isInitialSurveyUploaded");
      deviceIdUploaded = prefs.containsKey("isDeviceIdUploaded");
      pendingSurvey = prefs.containsKey("surveyID");

      // Get study credentials
      final studyCredentials = await getStudyFromAPIREST(code).timeout(timeoutValue);

      // [2] If the code has been received but any survey has been
      //     filled, just load backend and present informed consent
      if (!consentUploaded & !initialSurveyUploaded & !skipConsent) {
        // Initialize backend
        await CarpBackend().initialize(credentials: studyCredentials).timeout(timeoutValue);

        // Get informed consent task
        DocumentSnapshot informedConsent = await CarpService().documentById(studyCredentials['consent_id']).get().timeout(timeoutValue);
        consentTask = RPOrderedTask.fromJson(informedConsent.data);

        // Store user code in shared prefs
        prefs.setString("code", code);

      // [3] If the code has been received and the informed consent has been
      // sent, but the initial survey not, just present survey
      } else if (consentUploaded & !initialSurveyUploaded & !skipConsent) {
        // Initialize study
        await initStudy(studyCredentials: studyCredentials).timeout(timeoutValue);

        // Request app settings if necessary
        await Location().requestService();

        // Request ignore battery optimizations if necessary
        if (!await Permission.ignoreBatteryOptimizations.isGranted) {
          await Permission.ignoreBatteryOptimizations.request();
        }

        // Get initial survey task
        DocumentSnapshot initialSurvey = await CarpService().documentById(studyCredentials['initial_survey_id']).get().timeout(timeoutValue);
        initialSurveyTask = RPOrderedTask.fromJson(initialSurvey.data);

      // [4] If everything has been completed, initialize all and send to main
      // screen
      } else {

        if (skipConsent) prefs.setString("code", code); //TODO: remove for production

        // Initialize all
        await initializeAll(studyCredentials).timeout(timeoutValue);

        // Request app settings if necessary
        await Location().requestService();

        // Store device id in database
        if (!deviceIdUploaded) {
          await storeUser(code).timeout(timeoutValue);
        }

        // Retrieve survey if available
        if (pendingSurvey) {
          final surveyID =  Settings().preferences.getInt("surveyID");
          await markSurveyAsCompleted(surveyID).timeout(timeoutValue);
          Settings().preferences.remove("surveyID");
          await flutterLocalNotificationsPlugin.cancel(surveyID);
          DocumentSnapshot survey = await CarpService().documentById(surveyID).get().timeout(timeoutValue);
          surveyTask = RPOrderedTask.fromJson(survey.data);
        }
      }

      return true;
    } on InvalidCodeException catch (_) {
      requestAgain = true;
      _showDialog(Strings.invalidCodeError);
      return false;
    } on UnauthorizedException catch (_) {
      requestAgain = true;
      _showDialog(Strings.invalidCodeError);
      return false;
    } on ServerException catch (_) {
      if (code.isEmpty) {
        requestAgain = true;
        _showDialog(Strings.serverError);
      }
      serviceNotAvailable = true;
      return false;
    } on TimeoutException catch(_) {
      if (code.isEmpty) {
        requestAgain = true;
        _showDialog(Strings.serverError);
      }
      serviceNotAvailable = true;
      return false;
    }
  }

  // Show error dialogs
  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.error),
          content: Text(text),
          actions: [
            TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  // Mark completed survey in database
  Future<void> markSurveyAsCompleted(int surveyID) async {
    final code = Settings().preferences.getString("code");
    final uri = Uri.parse(apiRestUri + "/register_completed_survey");
    Map<String, dynamic> payload = {"code": code, "survey_id": surveyID};
    final response = await http.post(uri,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 500 || response.statusCode == 503) {
      throw new ServerException();
    }
  }

  // Store user and device IDs in database
  Future<void> storeUser(String code) async {
    final uri = Uri.parse(apiRestUri + "/register_device");
    Map<String, dynamic> payload = {"participant_code": code.substring(0,5), "device_id": Settings().preferences.get('postcovid-ai app.user_id')};
    final response = await http.post(uri,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 500 || response.statusCode == 503) {
      throw new ServerException();
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isDeviceIdUploaded", true);
    }
  }

  /// Widget builder

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: login(context, this.widget.text),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Wait for validation
            return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: AutoSizeText(
                            Strings.loadingText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18
                            ),
                            maxLines: 2,
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        CircularProgressIndicator()
                      ],
                    )));
          } else if (!requestAgain) {
            if (!serviceNotAvailable) {
              if (!consentUploaded & !initialSurveyUploaded & !skipConsent) {
                return InformedConsentPage(consentTask: consentTask, code: this.widget.text);
              } else if (consentUploaded & !initialSurveyUploaded & !skipConsent) {
                return SurveyPage(surveyTask: initialSurveyTask, code: this.widget.text);
              } else {
                return pendingSurvey
                    ? SurveyPage(surveyTask: surveyTask, code: this.widget.text)
                    : PostcovidAIApp();
              }
            } else {
              return ServiceNotAvailablePage(Strings.serviceNotAvailableText, false);
            }
          } else {
            return LoginPage();
          }
      }
    );
  }
}

/// Functions shared between UI and foreground service

Future<Map> getStudyFromAPIREST(String code) async {
  final uri = Uri.parse(apiRestUri + "/get_study");
  Map<String, dynamic> payload = {"code": code};
  final response = await http.post(uri,
      body: jsonEncode(payload),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 500 || response.statusCode == 503) {
    throw new ServerException();
  } else {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == 500) {
      throw new ServerException();
    } else if (jsonResponse['status'] == 400) {
      throw new InvalidCodeException();
    } else if (jsonResponse['status'] == 403) {
      throw new UnauthorizedException();
    } else {
      return jsonResponse['data'];
    }
  }
}

void longTaskStartTracking() {
  activityRecognition.startStream(runForegroundService: false);
}

Future<int> getSurveyID() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String code = prefs.getString("code");
  final uri = Uri.parse(apiRestUri + "/get_survey_id");
    Map<String, dynamic> payload = {"code": code};
    final response = await http.post(uri,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 500 || response.statusCode == 503) {
      throw new ServerException();
    } else {
      Map jsonResponse = jsonDecode(response.body);
      if (response.statusCode != 200 || jsonResponse['status'] != 200) {
        return null;
      }
      else {
        return jsonResponse['data']['survey_id'];
      }
    }
}

/// Foreground service main

serviceMain() async {
  bool useAR = true;
  bool useBloc = true;
  bool _isConnected = true;
  bool uiPresent = true;
  
  WidgetsFlutterBinding.ensureInitialized();
  var i = 0;

  Future<bool> isConnected() async {
    try {
      final response = await InternetAddress.lookup("www.google.com");
      return response.isNotEmpty ? true : false;
    } on SocketException catch (err) {
      info(err.message);
      return false;
    }
  }

  Future<dynamic> myDartCode(Map<String, dynamic> initialData) async {
    _isConnected = await isConnected();
    String myPackage = AppServiceData.fromJson(initialData).mensaje;

    String notificationMessage = "Comenzando...";
    appServiceData.miNotificationTitle = notificationMessage;
    if (_isConnected) {
      if (useAR) {
        longTaskStartTracking();
      }
      if (useBloc) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String code = prefs.getString("code");

        final studyCredentials = await getStudyFromAPIREST(code);

        if (studyCredentials != null) {
          await bloc.initialize();
          await CarpBackend().initialize(credentials: studyCredentials);
          await Sensing().initialize(credentials: studyCredentials);

          if (!bloc.isRunning) {
            bloc.resume();
          }
        }

      }
      while (true) {

        int surveyID = await getSurveyID();
        if(surveyID != null) {
          final notificationService = NotificationService();
          await notificationService.init();

          AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'surveyChannelID', 'surveyChannel', 'Survey Channel',
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showWhen: false,
              icon: 'survey_icon',
              visibility: NotificationVisibility.public);

          IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails(
              presentAlert: false, presentBadge: true, presentSound: true);

          final platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iOSPlatformChannelSpecifics);
          await Settings().preferences.setInt("surveyID", surveyID);
          await notificationService.flutterLocalNotificationsPlugin.show(
              surveyID,
              Strings.appName,
              Strings.surveyNotificationText,
              platformChannelSpecifics,
              payload: 'item x');
        }
        appServiceData.progress = i;
        ServiceClient.update(appServiceData);

        await ServiceClient.sendAck().timeout(const Duration(seconds: 3), onTimeout: () {
          return "timeout";
        });
        await Future.delayed(const Duration(seconds: 60));
        i += 1;
      }
    }
  }

  Future<dynamic> myEndDartCode() async {
    if (bloc.isRunning){
      bloc.pause();
    }
  }

  Future<dynamic> myUiPresentCode() async {
    uiPresent = true;
  }

  Future<dynamic> myUiNotPresentCode() async {
    uiPresent = false;
  }

  ServiceClient.setExecutionCallback(
      myDartCode, myEndDartCode, myUiPresentCode, myUiNotPresentCode);
}
