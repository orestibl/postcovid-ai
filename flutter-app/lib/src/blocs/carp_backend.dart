part of postcovid_ai;

class CarpBackend {
  static CarpBackend _instance = CarpBackend._();

  CarpBackend._() : super();

  factory CarpBackend() => _instance;

  CarpApp _app;

  // Dummy object to register json deserialization functions
  RPTask rpTask = new RPTask('ignored');

  CarpApp get app => _app;

  Future initialize({Map credentials}) async {
    _app = CarpApp(
      name: "CANS Production @ UGR",
      uri: Uri.parse(uri),
      oauth: OAuthEndPoint(clientID: credentials['client_id'], clientSecret: credentials['client_secret']),
    );

    // Configure and authenticate
    CarpService().configure(app);
    await CarpService().authenticate(username: credentials['username'], password: credentials['password']);

    CarpDeploymentService().configureFrom(CarpService());
    CANSProtocolService().configureFrom(CarpService());

    info('$runtimeType initialized');
  }
}
