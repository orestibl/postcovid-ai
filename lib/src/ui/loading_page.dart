part of postcovid_ai;

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
