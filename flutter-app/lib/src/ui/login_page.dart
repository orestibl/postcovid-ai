part of postcovid_ai;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: size.height / 4,
                  child: Stack(
                      children: <Widget>[
                        Container(
                          color: AppTheme.DARK_COLOR,
                        ),
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOutQuad,
                          top: 0.0,//keyboardOpen ? -size.height / 3.7 : 0.0,
                          child: WaveWidget(
                            size: size,
                            yOffset: size.height / 4 - 50,
                            color: Colors.white,
                          ),
                        ),
                      ]
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                  child: Text(
                    'Bienvenido a POSTCOVID-AI',
                    //textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.DARK_COLOR,
                      fontSize: 34.0,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: Material(
                  elevation: 3.0,
                  shadowColor: Colors.grey,
                  child: TextField(
                    obscureText: false,
                    controller: textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.DARK_COLOR, width: 2.0)
                      ),
                      border: OutlineInputBorder(),
                      labelText: Strings.loginLabel,
                      hintText: Strings.loginHint,
                      labelStyle: TextStyle(color: AppTheme.DARK_COLOR)
                    ),
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: AppTheme.DARK_COLOR,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            LoadingPage(text: textController.text)));
                  },
                  child: Text(
                    Strings.send,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(
                height: 130,
              ),
            ],
          ),
        ),
      )
    );
  }
}