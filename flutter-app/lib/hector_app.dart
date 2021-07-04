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
  String _status = "";

  //String _result = "";
  String miTexto = "";

  //bool notificationListenerSet = false;
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
    milog.info("HH_ initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initLocationTrackingParameters();
    miLongTaskStreamSuscription =
        getLongTaskStreamSuscription(); //aquí puedes aprovechar para ver si está la long task running si quieres
    isServiceRunning().then((running) {
      if (running) {
        print("HH_ Service was already running -> binding it to my app");
        startService(null);
      } else {
        print(
            "HH_ Service wasn't running. Preferable to do the binding with await before AppClient.prepareExecute");
      }
    });
    AppClient.sendAppResumed();
    setNotificationListener();
    milog.info("HH_setNotificationListener");
    checkAndConfigureNotificationsAndroid(); // esto lanza un thread que arrancará bloc if needed
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    milog.info(
        "HH_didChangeAppLifecycleState de main.dart: ${state.toString()}");
    // if (state == AppLifecycleState.inactive ||
    //     state == AppLifecycleState.paused)
    if (state == AppLifecycleState.inactive) {
      // mucho ojo, cuando se le piden los permisos al principio o cada vez que miras la notificación de arriba se ejecuta esto!!!
      AppClient.sendAppPaused();
      // milog.info("HH_ cancelo miLongTaskStreamSuscription");
      // miLongTaskStreamSuscription?.cancel();
      // miLongTaskStreamSuscription = null;
      milog.info(
          "HH_ paro bloc: NO!!! lo paras cuando sepas que la notificación ha llegado y hay que re-hacerlo");
      if (finalizeApp) {
        milog.severe("HH_ EJECUTO SystemNavigator.pop()");
        SystemNavigator.pop();
      }
      // debería desactivar el listener de las notificaciones? Al menos pongo el "if mounted..."
    }
    if (state == AppLifecycleState.resumed) {
      AppClient.sendAppResumed();
      // milog.info("HH_ vuelvo a activar miLongTaskStreamSuscription");
      // if (miLongTaskStreamSuscription == null) {
      //   miLongTaskStreamSuscription = getLongTaskStreamSuscription();
      // }
      runInitStudyIfPendingNotificationViaSharedPrefs();
    }
    if (state == AppLifecycleState.detached) {
      // esto no hace falta. Se hace desde onDetachedFromActivity() del plugin (de hecho, es lo mejor ya que no sabemos si se hace el detached de esta clase pero la app sigue en el caso de UI más complejas)
      //AppClient.sendAppDetached();
      milog.info("HH_ AppLifecycleState.detached");
      milog.info("HH_ cancelo miLongTaskStreamSuscription");
      miLongTaskStreamSuscription?.cancel();
      miLongTaskStreamSuscription = null;
      //WidgetsBinding.instance.removeObserver(this); // no pongas esto aquí. En todo caso en dispose...
      userTaskEventsHandler?.cancel();
      // y no se puede hacer algo parecido con activityStream (no tiene suscripcion??)
    }
  }

  void handleClick(String value) async {
    switch (value) {
      case 'initializeStudy':
        initStudy(resume: false);
        break;
      case 'runStudy':
        runStudy();
        break;
      case 'stopStudy':
        stopStudy();
        break;
      case 'isServiceRunning':
        checkIsServiceRunning();
        break;
      case 'startService': //ejecútalo solo si es necesario aunque no daña ejecutarlo varias veces aunque esté el servicio running
        startService(appServiceData);
        break;
      case 'prepareLongTask':
        prepareLongTask(appServiceData);
        break;
      case 'runLongTask':
        runLongTask();
        await Future.delayed(Duration(milliseconds: 1000));
        milog.severe(
            "HH_ y ahora salimos de la app. Primero background y luego detached");
        finalizeApp = true;
        goBackround();
        break;
      case 'stopLongTask':
        stopLongTask();
        break;
      case 'Go Backgound':
        goBackround();
        break;
      case 'initActivityTracking':
        initActivityTracking();
        break;
      case 'startLocationTracking':
        startLocationTracking();
        break;
      case 'stopLocationTracking':
        stopLocationTracking();
        break;
      case 'onGetCurrentLocation':
        onGetCurrentLocation();
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
          //IconButton(icon: Icon(Icons.play_arrow), onPressed: runLongTask),
          //IconButton(icon: Icon(Icons.stop), onPressed: stopServiceMain),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                'initializeStudy',
                // 'runStudy',
                // 'stopStudy',
                'initActivityTracking',
                // 'isServiceRunning',
                // 'startService',
                'prepareLongTask',
                'runLongTask',
                'stopLongTask',
                // 'Go Backgound',
                // 'onGetCurrentLocation',
                // 'startLocationTracking',
                // 'stopLocationTracking',
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
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(height: 20, width: double.infinity, child: Text(_status)),
          Container(
            height: 300,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.pink,
                child: Text(
                  miTexto,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override // no parece que se ejecute nunca
  void dispose() {
    print(
        "HH_dispose de main.dart}"); //hago print y no milog.info por si acaso...
    super.dispose();
    //bloc.dispose(); throw CARPBackendException('stop() is not supported.');
    WidgetsBinding.instance.removeObserver(this);
    // ¿quito listener de las notifications?
  }

  /// funciones relacionaldas con las notificaciones
  Future<void> checkAndConfigureNotificationsAndroid() async {
    milog.info("HH_checkAndConfigureNotificationsAndroid de main()");

    final NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      if (notificationAppLaunchDetails != null) {
        var selectedNotificationPayload = notificationAppLaunchDetails.payload;
        milog.info(
            "HH_ La notif despertó la app, payload = $selectedNotificationPayload");
        notifTaskName = selectedNotificationPayload;

        // Ahora inicializo el nuevo bloc para que genere la task
        initStudy(resume: true, useTaskNameFiltering: true); //no pongo await
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
      milog.info('HH_notification payload: $payload');
      if (payload != null) {
        //milog.info('HH_notification payload: $payload');
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
        milog.info("HH_notificación pendiente: payload= $pendingNotification");
        notifTaskName = pendingNotification;
        initStudy(resume: true, useTaskNameFiltering: true);
        //ahí se ponen las prefs otra vez a ""
      }
    });
  }

  /// funciones relacionadas con la long task que se ejecuta en serviceMain

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

  void prepareLongTask(AppServiceData appServiceData) async {
    if (await isServiceRunning()) {
      milog.severe(
          "Service already running. It is a bad idea to run prepareLongTask now!");
      return;
    }
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appServiceData.mensaje = packageInfo.packageName;
      await AppClient.startService(appServiceData);
      await AppClient.prepareExecute();
      // milog.info(
      //     "HH_DUERMO unos ms en main.dart antes de AppClient.execute() para dejar que se ejecute serviceMain del todo y cree los callbacks de su canal");
      // sleep(Duration(milliseconds: 500));
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
  }

  Future<void> runLongTask() async {
    // if (await isLongTaskRunning()) {
    //   milog.severe(
    //       "Long task already running. It is a bad idea to run it again now!");
    //   return;
    // }
    // miLongTaskStreamSuscription = getLongTaskStreamSuscription();
    // AppClient.sendAppResumed();
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
      //setState(() => _result = 'stop service');
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
    }
  }

  StreamSubscription<Map<String, dynamic>> getLongTaskStreamSuscription() {
    //aquí puedes aprovechar para ver si está la long task running si quieres ya que al llamar a observe internamente se puede comprobar eso
    try {
      return AppClient.observe.listen((json) {
        //if (mounted) {
        //var serviceData = AppServiceData.fromJson(json);
        // setState(() {
        milog.info("AppClient recibe lo siguiente: $json");
        // _status = serviceData.notificationDescription;
        // miTexto = miTexto + "\n" + _status;
        // });
        // }
      });
    } on PlatformException catch (e, stacktrace) {
      milog.info(e);
      milog.info(stacktrace);
      return null;
    }
  }

  Future<void> checkIsServiceRunning() async {
    bool running = await isServiceRunning();
    setState(() {
      miTexto = miTexto + "\n" + "isServiceRunning = $running";
    });
  }

  /// GO BACKGROUND
  void goBackround() {
    milog.info("goBackground");
    MoveToBackground.moveTaskToBack();
  }

  /// funciones relacionadas con bloc en la app principal

  Future<void> initStudy(
      {bool resume = true, bool useTaskNameFiltering = false}) async {
    if (initStudylocked) {
      milog.info(
          "HH_initStudy already in use"); //nunca me ha pasado, pero por si acaso
      return;
    }
    initStudylocked = true;
    milog.info(
        "HH_ en initStudy: resume=$resume, useTaskNameFiltering=$useTaskNameFiltering");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('PENDING_NOTIFICATION', "");

    if (bloc.isRunning) {
      stopStudy(); //para que lo pare y cancele suscripciones
    }
    // realmente no sirve de mucho blocAlreadyInitialized ya que una vez hecho
    // Sensing().initialize no podemos volver a la situación anterior y aunque
    // solo re-ejecute esa función con las nuevas tareas no consigo que se activen
    // los AppTaskController().userTaskEvents. En cualquier caso no es crítico
    // ya que salgo del programa una vez ejecutado runLongTask y todo se inicia
    // de nuevo (hay que procurar que el usuario no pinche en la notificación de
    // la nueva survey dentro del programa: solo sacará la survey correctamente
    // si no se ha hecho ningún blocAlreadyInitialized = false)
    if (blocAlreadyInitialized) {
      await Sensing()
          .initialize(taskName: useTaskNameFiltering ? notifTaskName : '',
      username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp",
      protocolName: "test_protocol_rp");
    } else {
      await bloc.initialize();
      await CarpBackend().initialize(username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp");
      blocAlreadyInitialized = true;
      await Sensing()
          .initialize(taskName: useTaskNameFiltering ? notifTaskName : '', username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp",
      protocolName: "test_protocol_rp");
    }
    if (resume) {
      //debes hacerlo aquí just después de await Sensing y no en otro lado porque init es una hebra y hay que esperar a que acabe
      runStudy(); //para que lo arranque e inicie suscripciones
    }
    initStudylocked = false;
  }

  void runStudy() {
    if (bloc.isRunning) {
      milog.severe("HH_bloc was already running. Nothing to start");
    } else {
      milog.info("HH_startStudy");
      bloc.resume();
      if (userTaskEventsHandler == null) {
        userTaskEventsHandler =
            AppTaskController().userTaskEvents.listen((event) {
          milog.info("HH_ nuevo evento de AppTaskController: $event");
          if (event.runtimeType == SurveyUserTask &&
              event.state == UserTaskState.enqueued) {
            milog.warning("HH_es de tipo SurveyUserTask y acaba de encolarse");
            // Ahora hay que mostrar la encuesta
            print(bloc.tasks.length);
            bloc.tasks.last.onStart(context);
            // ahora hay que esperar a que se complete y ponernos en background
            waitAndGo(); //Y ahora esperamos a que bloc.tasks.last.state==UserTaskState.done
          }
        });
        // setNotificationListener(); //no funciona si lo pongo aquí
        // milog.info("HH_setNotificationListener");
      }
    }
  }

  void stopStudy() {
    if (bloc.isRunning) {
      milog.info("HH_stopStudy");
      bloc.pause();
      try {
        bloc.stop();
      } catch (e, s) {
        milog.severe("Error al hacer bloc.stop: $e: $s");
      }
      userTaskEventsHandler?.cancel();
      userTaskEventsHandler = null;
    } else
      milog.severe("HH_bloc wasn't running. Nothing to stop");
  }

  Future<void> waitAndGo() async {
    int ticks = 50;
    while (true) {
      milog.warning("HH_waitAndGo: state=${bloc.tasks.last.state}");
      if (bloc.tasks.last.state == UserTaskState.done) {
        milog.severe("Conseguido!!! Salimos...");
        break;
      }
      ticks -= 1;
      if (ticks == 0) break;
      await Future.delayed(Duration(milliseconds: 500));
    }
    finalizeApp = true;
    goBackround();
  }

  /// ACTIVITY
  void initActivityTracking() async {
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
      activityStream =
          activityRecognition.startStream(runForegroundService: false);
      milog.info("HECTOR: _startTracking ahora llamo a listen de main.dart");
      //Tengo que llamar a listen desde la UI. ¿Basta con esto? Parece que sí
      activityStream.listen(null);
    }
  }

  void onData(ActivityEvent activityEvent) {
    milog.info("NEW ACTIVITY: ${activityEvent.toString()}");
  }

  /// LOCATION
  void initLocationTrackingParameters() {
    // Subscribe to stream in case it is already running
    locationManager.interval = 5;
    locationManager.distanceFilter = 0;
    locationManager.notificationTitle = 'CARP Location Example';
    locationManager.notificationMsg = 'CARP is tracking your location';
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onDataLocationTracking);
  }

  void onGetCurrentLocation() async {
    LocationDto dto = await locationManager.getCurrentLocation();
    print('Current location: $dto');
    print('Current location: ${dtoToString(dto)}');
  }

  void onDataLocationTracking(LocationDto dto) {
    print(dtoToString(dto));
    if (_statusLocation == LocationStatus.UNKNOWN) {
      _statusLocation = LocationStatus.RUNNING;
    }
    lastLocation = dto;
    lastTimeLocation = DateTime.now();
  }

  void startLocationTracking() async {
    // Subscribe if it hasn't been done already
    if (dtoSubscription != null) {
      dtoSubscription.cancel();
    }
    dtoSubscription = dtoStream.listen(onDataLocationTracking);
    await locationManager.start();
    _statusLocation = LocationStatus.RUNNING;
  }

  void stopLocationTracking() async {
    _statusLocation = LocationStatus.STOPPED;
    dtoSubscription.cancel();
    await locationManager.stop();
  }

  ///
}

/// ESTO ES LO QUE SE EJECUTA Y PERDURA EN EL TIEMPO - LONG TASK ///

void longTaskStartTracking() {
  print("HECTOR: _startTracking ahora llamo a startStream de main.dart");
  print("HECTOR: _startTracking pongo runForegroundService=false");
  var activityStream =
      activityRecognition.startStream(runForegroundService: false);
  print("HECTOR: _startTracking ahora llamo a listen de main.dart");
  activityStream.listen(onData2);
}

void onData2(ActivityEvent activityEvent) {
  print(activityEvent.toString());
  print("HECTOR: onData2 de main.dart");
}

serviceMain() async {
  bool useAR = true;
  bool useBloc = true;

  print("HH_main.dart, serviceMain");
  // print(arg);
  WidgetsFlutterBinding.ensureInitialized();
  var i = 0;
  var uiPresent = true;
  print(DateTime.now());

  Future<dynamic> myDartCode(Map<String, dynamic> initialData) async {
    // aquí no puedes usar milog!!!
    print(
        "HH_ main.dart Ejecutando la long task. Argumentos recibidos: ${initialData.toString()}");
    String myPackage = AppServiceData.fromJson(initialData).mensaje;
    if (myPackage != null) print("myPackage = $myPackage");

    String notificationMessage = "Comenzando...";
    appServiceData.miNotificationTitle = notificationMessage;
    if (useAR) {
      debugPrint("HECTOR: LLAMO A _startTracking desde el servicio");
      longTaskStartTracking();
    }
    if (useBloc) {
      await bloc.initialize();
      await CarpBackend().initialize(username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp");
      await Sensing().initialize(username: "googlePlay@test.dk", password: "googlePlay", clientID: "carp", clientSecret: "carp",
      protocolName: "test_protocol_rp"); //aquí debes llamar al "bueno", sin filtros
      if (!bloc.isRunning) bloc.resume();
      Sensing().controller.data.listen((event) {
        print("HH_NUEVO EVENTO: ${event.data.toString()}");
        appServiceData.progress = bloc.studyDeploymentModel.samplingSize;
        appServiceData.mensaje = event.toJson().toString();
        try {
          // no merece la pena esperar a que termine (await)
          ServiceClient.update(appServiceData);
        } catch (e, s) {
          print("Error al hacer update: $e $s");
        }
      });
      userTaskEventsHandler =
          AppTaskController().userTaskEvents.listen((event) {
        print("HH_ nuevo evento de AppTaskController: $event");
        if (event.runtimeType == SurveyUserTask &&
            event.state == UserTaskState.enqueued) {
          print(
              "HH_es de tipo SurveyUserTask -> la desencolo: se encargará la app pral con UI");
          print("HH_esto hay que hacerlo en el servicio y no aquí en la UI!!!");
          // se lo hago saber a la app principal y le digo que pase esa encuesta
          // y la desencolo
          AppTaskController().dequeue(event.id);
          // List<UserTask> lista = AppTaskController().userTaskQueue;
          // AppTaskController().dequeue(lista[0].id);
        }
      });
    }
    while (true) {
      print('dart -> $i');
      appServiceData.progress = i;
      print("envío SeviceClient.update: así puedo mantener conexión???");
      try {
        // no merece la pena esperar a que termine (await)
        ServiceClient.update(appServiceData);
      } catch (e, s) {
        print("Error al hacer update: $e $s");
      }

      if (!letAppGetClosed && !uiPresent) {
        print("Re-ejecutamos la app ya que letAppGetClosed = $letAppGetClosed");
        DeviceApps.openApp(myPackage);
      }

      var stringData = await ServiceClient.sendAck()
          .timeout(const Duration(milliseconds: 1000), onTimeout: () {
        return "timeout";
      });
      if (stringData == "timeout") {
        print("HH_ UFF!!! timeout al llamar a sendAck");
      } else {
        print(
            "HH_ supongo que ahora tendrás que recibir AckToLongTask en service_client.dart para ver si sigue vivo");
      }
      await Future.delayed(const Duration(seconds: 60));
      i += 1;
    }
  }

  Future<dynamic> myEndDartCode() async {
    print("HH_ main.dart myEndDartCode");
    //print("i= $i");
    // puedo acceder a las variables comunes definidas en ServiceMain y son las mismas variables
    userTaskEventsHandler?.cancel();
    if (bloc.isRunning) bloc.pause(); // al menos...
    //bloc.stop(); bloc.dispose(); throw CARPBackendException('stop() is not supported.');
  }

  Future<dynamic> myUiPresentCode() async {
    print("HH_ main.dart Recibo UI está presente");
    uiPresent = true;
  }

  Future<dynamic> myUiNotPresentCode() async {
    print("HH_ main.dart Recibo UI NO está presente");
    uiPresent = false;
  }

  ServiceClient.setExecutionCallback(
      myDartCode, myEndDartCode, myUiPresentCode, myUiNotPresentCode);
}