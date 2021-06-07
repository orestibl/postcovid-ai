library postcovid_ai;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'package:research_package/research_package.dart';

import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_audio_package/audio.dart';
// import 'package:carp_connectivity_package/connectivity.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_survey_package/survey.dart';
//import 'package:carp_communication_package/communication.dart';
//import 'package:carp_apps_package/apps.dart';

import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:carp_backend/carp_backend.dart';

import 'src/sensing/credentials.dart';

part 'src/app.dart';
part 'src/blocs/sensing_bloc.dart';
part 'src/blocs/carp_backend.dart';
part 'src/models/data_models.dart';
part 'src/models/deployment_model.dart';
part 'src/models/device_models.dart';
part 'src/models/probe_description.dart';
part 'src/models/probe_models.dart';
part 'src/sensing/sensing.dart';
part 'src/sensing/local_study_protocol_manager.dart';
part 'src/sensing/study_deployment_manager.dart';
part 'src/ui/cachet.dart';
part 'src/ui/homepage.dart';
part 'src/ui/surveys_page.dart';
part 'src/ui/informed_consent_page.dart';

void main() {
  runApp(App());
}
