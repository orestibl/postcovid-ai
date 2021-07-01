part of postcovid_ai;

Future<Map> getStudyFromAPIREST(String code) async {
  final uri = Uri.parse(apiRestUri + "/get_study");
  Map<String, dynamic> payload = {"code": code};
  final response = await http.post(uri,
      body: jsonEncode(payload), headers: {"Content-Type": "application/json"});
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

void foregroundServiceFunction() async {
  debugPrint("The current time is: ${DateTime.now()}");
  ForegroundService.notification.setText("The time was: ${DateTime.now()}");
  
  ///////////

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  String code = prefs.getString("code");
  final studyCredentials = await getStudyFromAPIREST(code);
  await bloc.initialize();

  // Initialize backend
  await CarpBackend().initialize(
      clientID: studyCredentials["client_id"],
      clientSecret: studyCredentials['client_secret'],
      username: studyCredentials['username'],
      password: studyCredentials['password']);

  await Sensing().initialize(
      username: studyCredentials['username'],
      password: studyCredentials['password'],
      clientID: studyCredentials['client_id'],
      clientSecret: studyCredentials['client_secret'],
      protocolName: studyCredentials['protocol_name'],
      askForPermissions: false);

  if (!bloc.isRunning) {
    bloc.resume();
  }
  ///////

  if (!ForegroundService.isIsolateCommunicationSetup) {
    ForegroundService.setupIsolateCommunication((data) {
      debugPrint("bg isolate received: $data");
    });
  }

  ForegroundService.sendToPort("message from bg isolate");
}

Future<void> startService() async {
  ///if the app was killed+relaunched, this function will be executed again
  ///but if the foreground service stayed alive,
  ///this does not need to be re-done
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(10);

    //necessity of editMode is dubious (see function comments)
    await ForegroundService.notification.startEditMode();
    await ForegroundService.notification.setPriority(AndroidNotificationPriority.LOW);

    await ForegroundService.notification
        .setTitle("Example Title: ${DateTime.now()}");
    await ForegroundService.notification
        .setText("Example Text: ${DateTime.now()}");

    await ForegroundService.notification.finishEditMode();

    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  }

  ///this exists solely in the main app/isolate,
  ///so needs to be redone after every app kill+relaunch
  await ForegroundService.setupIsolateCommunication((data) {
    debugPrint("main received: $data");
  });
}

class LoadingPage extends StatefulWidget {
  final String text;

  LoadingPage({Key key, this.text}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool skipConsent = true; //TODO: remove for production
  bool requestAgain = false;
  bool consentUploaded = false;
  bool initialSurveyUploaded = false;
  RPOrderedTask consentTask;
  
  Future<void> registerDevice(String code) async{
    final uri = Uri.parse(apiRestUri + "/register_device");
    Map<String, dynamic> payload = {"participant_code": code.substring(0,5),
                                    "device_id": await Settings().userId};
    final response = await http.post(uri, body: jsonEncode(payload), 
                    headers: {"Content-Type": "application/json"});
    print(response);
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

  Future<bool> login(BuildContext context, String code) async {
    try {
      if (code.isEmpty) {
        requestAgain = true;
        return true;
      }
      // Get study credentials
      final studyCredentials = await getStudyFromAPIREST(code);

      // Initialize bloc
      await bloc.initialize();

      // Initialize backend
      await CarpBackend().initialize(
          clientID: studyCredentials["client_id"],
          clientSecret: studyCredentials['client_secret'],
          username: studyCredentials['username'],
          password: studyCredentials['password']);

      // Check if consent and initial survey have been uploaded
      consentUploaded = await isConsentUploaded();
      initialSurveyUploaded = await isInitialSurveyUploaded();

      // Store the initial survey ID in shared preferences
      if (!initialSurveyUploaded & !skipConsent) //TODO: modify for production
        Settings().preferences.setInt('initialSurveyID', 5);//studyCredentials['initial_survey_id']);

      // Only initialize sensing if the consent is already uploaded
      if (!consentUploaded & !skipConsent) { //TODO: modify for production
        DocumentSnapshot informedConsent = await CarpService().documentById(studyCredentials['consent_id']).get();
        consentTask = RPOrderedTask.fromJson(informedConsent.data);
      } else {
        await Sensing().initialize(
            username: studyCredentials['username'],
            password: studyCredentials['password'],
            clientID: studyCredentials['client_id'],
            clientSecret: studyCredentials['client_secret'],
            protocolName: studyCredentials['protocol_name']);
      }

      // Save user code in shared preferences
      await saveCode(code);
      await registerDevice(code);
      await startService();
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
  }

  Future<bool> isConsentUploaded() async {
    return Settings().preferences.containsKey("isConsentUploaded");
  }

  Future<bool> isInitialSurveyUploaded() async {
    return Settings().preferences.containsKey("isInitialSurveyUploaded");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //TODO: Should we return another MaterialApp? Or just the FutureBuilder?
        theme: AppTheme.theme,
        home: FutureBuilder(
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
            }));
  }
}
