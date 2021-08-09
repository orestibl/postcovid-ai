part of postcovid_ai;

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  static const String routeName = '/study';

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  _HomePageState() : super();

  Widget build(BuildContext context) => _buildHomePage(context);

  Widget _buildHomePage(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Strings.appName),
          centerTitle: true,
        ),
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      Strings.homePageText1,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text(
                    Strings.homePageText2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                      child: Text(Strings.contactEmail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.DARK_COLOR)),
                      onTap: () async {
                        var url = 'mailto:' + Strings.contactEmail;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Cannot launch $url';
                        }
                      })
                ])));
  }
}
