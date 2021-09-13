part of postcovid_ai;

class ServiceNotAvailablePage extends StatefulWidget {
  const ServiceNotAvailablePage({Key key}) : super(key: key);

  _ServiceNotAvailablePageState createState() => _ServiceNotAvailablePageState();
}
class _ServiceNotAvailablePageState extends State<ServiceNotAvailablePage> with WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String code = "";

  final notConnectedSnackBar = SnackBar(content: Text(Strings.serviceNotAvailableSnackBar));
  final connectedSnackBar = SnackBar(content: Text(Strings.serviceAvailableSnackBar));

  _ServiceNotAvailablePageState() : super();

  Future<void> checkConnection() async {
    // Check internet connection
    try {
      final response = await InternetAddress.lookup("www.google.com");
      if (response.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey("code")) {
          code = prefs.getString("code");
        }
        ScaffoldMessenger.of(context).showSnackBar(connectedSnackBar);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoadingPage(text: code)
        ));
      }
    } on SocketException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(notConnectedSnackBar);
      info(err.message);
    }
  }

  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed)
        checkConnection();
    });
  }

  @override
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
                  width: 150,
                  height: 125,
                  child: Image.asset('assets/logo/app_icon.png')),
              SizedBox(height: 40),
              AutoSizeText(
                Strings.serviceNotAvailableText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
                maxLines: 9,
              ),
              SizedBox(height: 30),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: AppTheme.DARK_COLOR,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                    onPressed: () => checkConnection(),
                    child: Text(
                      Strings.retry,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18),
                    )
                )
              )
            ]
        )
      )
    );
  }
}
