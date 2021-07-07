part of postcovid_ai;

class AppDebug extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: AppDebugHome(),
    );
  }
}

class AppDebugHome extends StatefulWidget {
  const AppDebugHome({Key key}) : super(key: key);

  @override
  _AppDebugHomeState createState() => _AppDebugHomeState();
}

class _AppDebugHomeState extends State<AppDebugHome>
    with WidgetsBindingObserver {


  StreamSubscription<Map<String, dynamic>> miLongTaskStreamSuscription;
  StreamSubscription<UserTask> userTaskEventsHandler;
  String notifTaskName = 'no_task_so_remove_all_of_them';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Stream<ActivityEvent> activityStream;
  bool initStudylocked = false;
  bool finalizeApp = false;
  bool blocAlreadyInitialized = false;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      AppClient.sendAppPaused();
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
  
  Future<void> initializeAll() async {
    await initStudy(resume: false);
    await initActivityTracking();
    await prepareLongTask(appServiceData);
    await runLongTask();
    await Future.delayed(Duration(milliseconds: 1000));
    finalizeApp = true;
    goBackround();
  }

  void handleClick(String value) async {
    switch (value) {
      case 'RUN ALL': 
        initializeAll();
        break;
      case 'initializeStudy':
        initStudy(resume: false);
        break;
      case 'prepareLongTask':
        prepareLongTask(appServiceData);
        break;
      case 'runLongTask':
        runLongTask();
        await Future.delayed(Duration(milliseconds: 1000));
        finalizeApp = true;
        goBackround();
        break;
      case 'stopLongTask':
        stopLongTask();
        break;
      case 'initActivityTracking':
        initActivityTracking();
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Titulo de la AppBar"),
        actions: [
          IconButton(
              icon: Icon(Icons.update),
              onPressed: () {
                setState(() {});
              }),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                'initializeStudy',
                'initActivityTracking',
                'prepareLongTask',
                'runLongTask',
                'stopLongTask',
                'RUN ALL'
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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


  void startService(AppServiceData appServiceData) async {
    try {
      await AppClient.startService(appServiceData);
    } on PlatformException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
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

  void stopLongTask() async {
    try {
      await AppClient.stopService();
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
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

  void goBackround() {
    MoveToBackground.moveTaskToBack();
  }


  Future<void> initStudy({bool resume = true, 
  bool useTaskNameFiltering = false}) async {  //TODO corresponde a loading_page.login (hay que añadir blocAlreadyInitialized)
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
    if (blocAlreadyInitialized) {
      await Sensing().initialize(taskName: taskName, 
      username: "googlePlay@test.dk", password: "googlePlay", 
      clientID: "carp", clientSecret: "carp", protocolName: "test_protocol_rp");
    } else {
      await bloc.initialize();
      await CarpBackend().initialize(username: "googlePlay@test.dk",
       password: "googlePlay", clientID: "carp", clientSecret: "carp");
      blocAlreadyInitialized = true;
      await Sensing().initialize(taskName: taskName,
           username: "googlePlay@test.dk", password: "googlePlay", 
           clientID: "carp", clientSecret: "carp",
           protocolName: "test_protocol_rp");
    }
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
            waitAndGo();
          }
        });
      }
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

  Future<void> waitAndGo() async {
    int ticks = 50;
    while (bloc.tasks.last.state != UserTaskState.done && ticks != 0) {
      ticks -= 1;
      await Future.delayed(Duration(milliseconds: 500));
    }
    finalizeApp = true;
    goBackround();
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
  

  /// LOCATION
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

}

void longTaskStartTracking() {
  activityRecognition.startStream(runForegroundService: false);
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
      await bloc.initialize();
      await CarpBackend().initialize(username: "googlePlay@test.dk", 
      password: "googlePlay", clientID: "carp", clientSecret: "carp");
      await Sensing().initialize(username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp",
      protocolName: "test_protocol_rp");
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
          // y la desencolo
          AppTaskController().dequeue(event.id);
        }
      });
    }
    while (true) {
      appServiceData.progress = i;
      ServiceClient.update(appServiceData);

      if (!letAppGetClosed && !uiPresent) {
        DeviceApps.openApp(myPackage);
      }

      await ServiceClient.sendAck().timeout(const Duration(milliseconds: 1000)/*, onTimeout: () {
        return "timeout";
      }*/);
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