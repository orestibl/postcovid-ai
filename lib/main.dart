library postcovid_ai;

import 'dart:async';

import 'package:carp_audio_package/audio.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:carp_connectivity_package/connectivity.dart';
// import 'package:carp_connectivity_package/connectivity.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
//import 'package:carp_communication_package/communication.dart';
//import 'package:carp_apps_package/apps.dart';

import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

import 'src/sensing/credentials.dart';

part 'src/app.dart';
part 'src/blocs/sensing_bloc.dart';
part 'src/models/data_models.dart';
part 'src/models/deployment_model.dart';
part 'src/models/device_models.dart';
part 'src/models/probe_description.dart';
part 'src/models/probe_models.dart';
part 'src/sensing/sensing.dart';
part 'src/sensing/study_protocol_manager.dart';
part 'src/ui/cachet.dart';
part 'src/ui/homepage.dart';
part 'src/ui/surveys_page.dart';

void startForegroundService() async {
  ForegroundServiceHandler.notification.setTitle("PostCOVID-AI");
  ForegroundServiceHandler.notification.setText("App is sensing");
  ForegroundService().start();
  debugPrint("Started service");
}

void main() {
  runApp(App());
  //startForegroundService();
}
