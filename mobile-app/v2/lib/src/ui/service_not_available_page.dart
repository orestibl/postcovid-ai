import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../my_logger.dart';
import '../app_theme.dart';
import '../strings.dart';
import 'loading_page.dart';

class ServiceNotAvailablePage extends StatefulWidget {
  final String pageText;
  final String loadingText;
  final bool connectionNotAvailable;

  const ServiceNotAvailablePage(
      this.pageText, this.loadingText, this.connectionNotAvailable,
      {Key? key})
      : super(key: key);

  @override
  ServiceNotAvailablePageState createState() => ServiceNotAvailablePageState();
}

class ServiceNotAvailablePageState extends State<ServiceNotAvailablePage>
    with WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  String code = "";

  final notConnectedSnackBar =
      SnackBar(content: Text(Strings.connectionNotAvailableSnackBar));
  final connectedSnackBar =
      SnackBar(content: Text(Strings.connectionAvailableSnackBar));

  ServiceNotAvailablePageState() : super();

  Future<void> checkConnection() async {
    // ver https://www.youtube.com/watch?v=bzWaMpD1LHY
    final messenger = ScaffoldMessenger.of(context);
    // Check internet connection
    try {
      final response = await InternetAddress.lookup("www.google.com");
      if (response.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        // Get code
        if (prefs.containsKey(SHARED_CODE)) {
          code = prefs.getString(SHARED_CODE) ?? "";
        }
        // Retry
        if (widget.connectionNotAvailable) {
          messenger.showSnackBar(connectedSnackBar);
        }
        // ver https://www.youtube.com/watch?v=bzWaMpD1LHY
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  LoadingPage(code: code, loadingText: widget.loadingText)));
        }
      }
    } on SocketException catch (err) {
      messenger.showSnackBar(notConnectedSnackBar);
      milog.info(err.message);
    }
  }

  @override
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
      if (state == AppLifecycleState.resumed) checkConnection();
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/logo/app_icon.png')),
              const SizedBox(height: 40),
              AutoSizeText(
                widget.pageText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                maxLines: 9,
              ),
              const SizedBox(height: 30),
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
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
