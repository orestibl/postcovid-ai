part of postcovid_ai;

class CarpBackend {
  static CarpBackend _instance = CarpBackend._();

  CarpBackend._() : super();

  factory CarpBackend() => _instance;

  CarpApp _app;

  String consentID;

  CarpApp get app => _app;

  Future initialize(
      {String clientID,
      String clientSecret,
      String username,
      String password}) async {
    _app = CarpApp(
      name: "CANS Production @ UGR",
      uri: Uri.parse(uri),
      oauth: OAuthEndPoint(clientID: clientID, clientSecret: clientSecret),
    );

    // Configure and authenticate
    CarpService().configure(app);
    await CarpService().authenticate(username: username, password: password);

    CarpDeploymentService().configureFrom(CarpService());
    CANSProtocolService().configureFrom(CarpService());

    info('$runtimeType initialized');
  }
}