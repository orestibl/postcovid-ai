part of postcovid_ai;

class LoadingPage extends StatefulWidget {
  final String text;

  LoadingPage({Key key, this.text}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver{
  bool skipConsent = true; //TODO: remove for production
  bool requestAgain = false;
  bool consentUploaded = false;
  bool initialSurveyUploaded = false;
  RPOrderedTask consentTask;
  bool finalizeApp = false;
  bool initStudylocked = false;
  String notifTaskName = 'no_task_so_remove_all_of_them';
  bool blocAlreadyInitialized = false;
  StreamSubscription<UserTask> userTaskEventsHandler;
  Stream<ActivityEvent> activityStream;
  StreamSubscription<Map<String, dynamic>> miLongTaskStreamSuscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
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
      runInitStudyIfPendingNotificationViaSharedPrefs();
    }
    if (state == AppLifecycleState.detached) {
      miLongTaskStreamSuscription?.cancel();
      miLongTaskStreamSuscription = null;
      userTaskEventsHandler?.cancel();
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initLocationTrackingParameters();
    miLongTaskStreamSuscription = getLongTaskStreamSuscription();
    isServiceRunning().then((running) {
      if (running) {
        startService(null);
      }
    });
    AppClient.sendAppResumed();
    setNotificationListener();
    checkAndConfigureNotificationsAndroid(); // esto lanza un thread que arrancará bloc if needed
  }
  void startService(AppServiceData appServiceData) async {
    try {
      await AppClient.startService(appServiceData);
    } on PlatformException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }
  Future<void> checkAndConfigureNotificationsAndroid() async {

    final NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      if (notificationAppLaunchDetails != null) {
        var selectedNotificationPayload = notificationAppLaunchDetails.payload;
        notifTaskName = selectedNotificationPayload;
        initStudy(resume: true, useTaskNameFiltering: true); 
      }
    } else
      runInitStudyIfPendingNotificationViaSharedPrefs();
  }
  void setNotificationListener() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        notifTaskName = payload;
        // Ahora inicializo el nuevo bloc para que genere la task
        initStudy(resume: true, useTaskNameFiltering: true); //no pongo await
      }
    });
  }
  
  
  void runInitStudyIfPendingNotificationViaSharedPrefs() {
    SharedPreferences.getInstance().then((prefs) {
      String pendingNotification = prefs.getString('PENDING_NOTIFICATION');
      if (pendingNotification != null && pendingNotification != "") {
        notifTaskName = pendingNotification;
        initStudy(resume: true, useTaskNameFiltering: true);
      }
    });
  }
  
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
  
  void initLocationTrackingParameters() {
    locationManager.interval = 5;
    locationManager.distanceFilter = 0;
    locationManager.notificationTitle = 'CARP Location Example';
    locationManager.notificationMsg = 'CARP is tracking your location';
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onDataLocationTracking);
  }

  void onDataLocationTracking(LocationDto dto) {
    if (_statusLocation == LocationStatus.UNKNOWN) {
      _statusLocation = LocationStatus.RUNNING;
    }
    lastLocation = dto;
    lastTimeLocation = DateTime.now();
  }

  

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
  
  Future<void> initializeAll(Map studyCredentials) async {
    await initStudy(resume: false, studyCredentials: studyCredentials);
    await initActivityTracking();
    await prepareLongTask(appServiceData);
    await Future.delayed(Duration(milliseconds: 500));
    await runLongTask();
    finalizeApp = true;
    //goBackround();
  }
  Future<void> initStudy({bool resume = true, bool useTaskNameFiltering = false, 
    Map studyCredentials}) async {
    if (initStudylocked) {
      return;
    }
    initStudylocked = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('PENDING_NOTIFICATION', "");

    if (bloc.isRunning) {
      stopStudy();
    }
    final taskName = useTaskNameFiltering ? notifTaskName : '';
    //if (!blocAlreadyInitialized) {
    await bloc.initialize();
    await CarpBackend().initialize(clientID: studyCredentials["client_id"],
        clientSecret: studyCredentials['client_secret'],
        username: studyCredentials['username'],
        password: studyCredentials['password']);
    blocAlreadyInitialized = true;
    //}
    await Sensing().initialize(taskName: taskName,
        username: studyCredentials['username'],
        password: studyCredentials['password'],
        clientID: studyCredentials['client_id'],
        clientSecret: studyCredentials['client_secret'],
        protocolName: studyCredentials['protocol_name']);
    if (resume) {
      runStudy();
    }
    initStudylocked = false;
  }

  void runStudy() {
    if (!bloc.isRunning) {
      bloc.resume();
      if (userTaskEventsHandler == null) {
        userTaskEventsHandler = AppTaskController().userTaskEvents.listen((event) {
          if (event.runtimeType == SurveyUserTask && event.state == UserTaskState.enqueued) {
            bloc.tasks.last.onStart(context);
            //waitAndGo();
          }
        });
      }
    }
  }
  Future<void> initActivityTracking() async {
    /// Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }

    /// iOS does not
    else {
      _startTracking();
    }
  }
  
  void stopStudy() {
    if (bloc.isRunning) {
      bloc.pause();
      try {
        bloc.stop();
      } catch (e, s) {
        milog.severe("Error al hacer bloc.stop: $e: $s");
      }
      userTaskEventsHandler?.cancel();
      userTaskEventsHandler = null;
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

  Future<void> waitAndGo() async {
    int ticks = 50;
    while (bloc.tasks.last.state != UserTaskState.done && ticks != 0) {
      ticks -= 1;
      await Future.delayed(Duration(milliseconds: 500));
    }
    finalizeApp = true;
    //goBackround();
  }
  
  Future<bool> isServiceRunning() async {
    try {
      return await AppClient.isServiceRunning();
    } on PlatformException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
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

  Future<void> runLongTask() async {
    try {
      AppClient.execute();
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
  }
   void goBackround() {
    MoveToBackground.moveTaskToBack();
  }
  
  Future<void> markSurveyAsCompleted(int surveyID) async {
    final code = Settings().preferences.getString("code");
    final uri = Uri.parse(apiRestUri + "/register_completed_survey");
    Map<String, dynamic> payload = {"code": code, "survey_id": surveyID};
    await http.post(uri, body: jsonEncode(payload), 
        headers: {"Content-Type": "application/json"});
  }
  
  Future<void> showSurvey() async {
    final surveyID =  Settings().preferences.getInt("surveyID");
    final document = CarpService().documentById(surveyID);
    if (document != null) {
      DocumentSnapshot initialSurvey = await document.get();
      await markSurveyAsCompleted(surveyID);
    
      Settings().preferences.remove("surveyID");
      RPOrderedTask initialSurveyTask = RPOrderedTask.fromJson(initialSurvey.data);
      Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SurveyPage(surveyTask: initialSurveyTask, code: Settings().preferences.getString("code"))
      ));
    }
  }


  Future<bool> login(BuildContext context, String code) async {
    try {
      if (code.isEmpty) {
        requestAgain = true;
        return true;
      }
      // Get study credentials
      final studyCredentials = await getStudyFromAPIREST(code);
      await initializeAll(studyCredentials);
      if (Settings().preferences.containsKey("surveyID")) {
        showSurvey();
      }
      

      // Check if consent and initial survey have been uploaded
      consentUploaded = await isConsentUploaded();
      initialSurveyUploaded = await isInitialSurveyUploaded();

      // Store the initial survey ID in shared preferences
      if (!initialSurveyUploaded & !skipConsent) //TODO: modify for production
        Settings().preferences.setInt('initialSurveyID', studyCredentials['initial_survey_id']);

      // Only initialize sensing if the consent is already uploaded
      if (!consentUploaded & !skipConsent) { //TODO: modify for production
        DocumentSnapshot informedConsent = await CarpService().documentById(studyCredentials['consent_id']).get();
        consentTask = RPOrderedTask.fromJson(informedConsent.data);
      }

      // Save user code in shared preferences
      
      await saveCode(code);

      return true;
    } on InvalidCodeException catch (_) {
      requestAgain = true;
      // TODO the code must be validated in the flutter app to avoid giving hints about the code
      _showDialog("Invalid code");
      return false;
    } on UnauthorizedException catch (_) {
      requestAgain = true;
      _showDialog("Unauthorized");
      return false;
    } on ServerException catch (_) {
      requestAgain = true;
      _showDialog("Server error");
      return false;
    }
  }

  Future<void> saveCode(String code) async {
    Settings().preferences.setString("code", code);
    final uri = Uri.parse(apiRestUri + "/register_device");
    Map<String, dynamic> payload = {"participant_code": "12345", // TODO poner código correcto
                                    "device_id": 1234};
    await http.post(uri, body: jsonEncode(payload), 
        headers: {"Content-Type": "application/json"});
  }

  Future<bool> isConsentUploaded() async {
    return Settings().preferences.containsKey("isConsentUploaded");
  }

  Future<bool> isInitialSurveyUploaded() async {
    return Settings().preferences.containsKey("isInitialSurveyUploaded");
  }

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
                      children: [CircularProgressIndicator()],
                    )));
          } else if (!requestAgain) {
            // If everything was fine, proceed
            //return consentUploaded //TODO: modify for production
            return ((consentUploaded & !skipConsent) || (skipConsent))
                ? PostcovidAIApp()
                : InformedConsentPage(consentTask: consentTask, code: this.widget.text);
          } else {
            // Otherwise, return to login page
            return LoginPage();
          }
      }
    );
  }
}


Future<Map> getStudyFromAPIREST(String code) async {
    final uri = Uri.parse(apiRestUri + "/get_study");
    Map<String, dynamic> payload = {"code": code};
    final response = await http.post(uri,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"});
    Map jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 500 || jsonResponse['status'] == 500) {
      throw new ServerException(); // TODO handle all situations
    }
    if (jsonResponse['status'] == 400) {
      throw new InvalidCodeException(); // TODO validate code in flutter to skip this
    } else if (jsonResponse['status'] == 403) {
      throw new UnauthorizedException();
    } else {
      return jsonResponse['data'];
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
    Map jsonResponse = jsonDecode(response.body);
    if (response.statusCode != 200 || jsonResponse['status'] != 200) {
      return null;
    }
    else {
      return jsonResponse['data']['survey_id'];
    }
}
  

serviceMain() async {
  bool useAR = true;
  bool useBloc = true;
  
  WidgetsFlutterBinding.ensureInitialized();
  var i = 0;
  var uiPresent = true;

  Future<dynamic> myDartCode(Map<String, dynamic> initialData) async {
    String myPackage = AppServiceData.fromJson(initialData).mensaje;

    String notificationMessage = "Comenzando...";
    appServiceData.miNotificationTitle = notificationMessage;
    if (useAR) {
      longTaskStartTracking();
    }
    if (useBloc) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String code = prefs.getString("code");
     
      final studyCredentials = await getStudyFromAPIREST(code);
      await bloc.initialize();
      await CarpBackend().initialize(clientID: studyCredentials["client_id"],
          clientSecret: studyCredentials['client_secret'],
          username: studyCredentials['username'],
          password: studyCredentials['password']);
      await Sensing().initialize(username: studyCredentials['username'],
          password: studyCredentials['password'],
          clientID: studyCredentials['client_id'],
          clientSecret: studyCredentials['client_secret'],
          protocolName: studyCredentials['protocol_name']);
      if (!bloc.isRunning) {
        bloc.resume();
      }
      Sensing().controller.data.listen((event) {
        appServiceData.progress = bloc.studyDeploymentModel.samplingSize;
        appServiceData.mensaje = event.toJson().toString();
        ServiceClient.update(appServiceData);
      });
      userTaskEventsHandler = AppTaskController().userTaskEvents.listen((event) {
        if (event.runtimeType == SurveyUserTask && event.state == UserTaskState.enqueued) {
          // se lo hago saber a la app principal y le digo que pase esa encuesta
          // y la desencoloe
          AppTaskController().dequeue(event.id);
        }
      });
    }
    while (true) {
      
    int surveyID = await getSurveyID();
    if(surveyID != null) {
      final notificationService = NotificationService();
      await notificationService.init();
  
      notification.AndroidNotificationDetails androidPlatformChannelSpecifics =
          notification.AndroidNotificationDetails(
              'your channel id', 'your channel name', 'your channel description',
              importance: notification.Importance.max,
              priority: notification.Priority.high,
              showWhen: false);
  
      notification.IOSNotificationDetails iOSPlatformChannelSpecifics =
          notification.IOSNotificationDetails(
              presentAlert: false, presentBadge: true, presentSound: true);
  
      final platformChannelSpecifics = notification.NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await Settings().preferences.setInt("surveyID", surveyID);
      await notificationService.flutterLocalNotificationsPlugin.show(
          surveyID,
          'POSTCOVID-AI',
          'There is an available survey',
          platformChannelSpecifics,
          payload: 'item x');
    }
      appServiceData.progress = i;
      ServiceClient.update(appServiceData);

      if (!letAppGetClosed && !uiPresent) {
        DeviceApps.openApp(myPackage);
      }

      await ServiceClient.sendAck().timeout(const Duration(seconds: 3), onTimeout: () {
        return "timeout";
      });
      await Future.delayed(const Duration(seconds: 60));
      i += 1;
    }
  }

  Future<dynamic> myEndDartCode() async {
    userTaskEventsHandler?.cancel();
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
