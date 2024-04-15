import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../strings.dart';
import 'loading_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset('assets/logo/app_icon.png')),
                const SizedBox(height: 20),
                AutoSizeText(
                  Strings.loginText,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppTheme.DARK_COLOR, fontSize: 34),
                  maxLines: 2,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                Material(
                    elevation: 3.0,
                    shadowColor: Colors.grey,
                    child: TextField(
                      obscureText: false,
                      controller: textController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppTheme.DARK_COLOR, width: 2.0)),
                          border: const OutlineInputBorder(),
                          labelText: Strings.loginLabel,
                          hintText: Strings.loginHint,
                          labelStyle:
                              const TextStyle(color: AppTheme.DARK_COLOR)),
                    )),
                const SizedBox(height: 40),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: AppTheme.DARK_COLOR,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoadingPage(
                              code: textController.text,
                              loadingText: Strings.loadingAppText)));
                    },
                    child: Text(
                      Strings.send,
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
          ))),
    ));
  }
}
